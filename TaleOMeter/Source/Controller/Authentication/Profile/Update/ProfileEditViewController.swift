//
//  ProfileEditViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit

// MARK: - Protocol used for sending data back -
protocol ProfileEditDelegate: AnyObject {
    func didChangeProfileData(_ data: String, code: String)
}

class ProfileEditViewController: UIViewController {

    // MARK: - Weak Property -
    @IBOutlet weak var titleLabelL: UILabel!
    @IBOutlet weak var textField: UITextField!
    // Making this a weak variable, so that it won't create a strong reference cycle
    weak var delegate: PromptViewDelegate? = nil
    weak var profileDelegate: ProfileEditDelegate? = nil
    
    // MARK: - Public Property -
    var titleString = "Change Display Name"
    var fieldValue = ""
    
    // MARK: - Private Property -
    private var profileData: ProfileData?

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboard()
        if let pfData = Login.getProfileData() {
            profileData = pfData
        }
        self.textField.text = fieldValue
        if titleString == "Change Display Name" {
            self.titleLabelL.text = "Enter Your Display Name"
            self.textField.placeholder = "Enter Your Display Name"
            if let pfData = profileData {
                self.textField.text = pfData.Fname
            }
        } else if let pfData = profileData {
            self.textField.text = pfData.Email
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = titleString
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: false, titleInLeft: true, backImage: true, backImageColor: .red)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.textField.setError()
        }
    }
        
    private func updateProfileData() {
        self.view.endEditing(true)
        if let prof = profileData {
            if !Reachability.isConnectedToNetwork() {
                Core.noInternet(self)
                return
            }
            Core.ShowProgress(self, detailLbl: "Updating Profile")
            
            AuthClient.updateProfile(ProfileRequest(name: prof.User_code, display_name: titleString == "Change Display Name" ? self.textField.text! : prof.Fname, email: titleString == "Change Display Name" ? prof.Email : self.textField.text!)) { [self] result in
                if let response = result {
                    Login.storeProfileData(response)
                    if titleString == "Change Display Name" {
                        PromptVManager.present(self, verifyMessage: "Your name is Successfully Changed", isUserStory: true)
                    } else {
                        PromptVManager.present(self, verifyMessage: "Your Email ID is Successfully Changed", isUserStory: true)
                    }
                }
                Core.HideProgress(self)
            }
        } else {
            Toast.show("No Profile data found!")
        }
    }
    
    
    @IBAction func tapOnSubmit(_ sender: Any) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        if titleString == "Change Display Name" {
            if textField.text!.isBlank {
                Validator.showRequiredError(textField)
                return
            }
            self.updateProfileData()
        } else {
            if textField.text!.isBlank {
                Validator.showRequiredError(textField)
                return
            }
            if !textField.text!.isEmail {
                Validator.showError(textField, message: "Invalid email")
                return
            }
            self.updateProfileData()
        }
    }
}

// MARK: - PromptViewDelegate -
extension ProfileEditViewController: PromptViewDelegate {
    func didActionOnPromptButton(_ tag: Int) {
        //back to profile screen
        if let navControllers = self.navigationController?.children {
            for controller in navControllers {
                if controller is ProfileViewController {
                    if let del = self.profileDelegate {
                        del.didChangeProfileData(self.textField.text!, code: "")
                    }
                    self.navigationController?.popToViewController(controller, animated: true)
                }
            }
        }
    }
}


extension ProfileEditViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.setError()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text!.isBlank {
            Validator.showRequiredError(textField)
            return
        }
        if titleString != "Change Display Name" && !textField.text!.isEmail {
            Validator.showError(textField, message: "Invalid email")
            return
        }
    }
}
