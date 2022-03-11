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
    var titleString = "Change Name"
    var fieldValue = ""
    
    // MARK: - Private Property -
    private var profileData: ProfileData?

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let pfData = Login.getProfileData() {
            profileData = pfData
        }
        self.textField.text = fieldValue
        if titleString == "Change Name" {
            self.titleLabelL.text = "Enter your name"
            self.textField.placeholder = "Enter your name"
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
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: false)
    }
        
    private func updateProfileData() {
        if let prof = profileData {
            Core.ShowProgress(self, detailLbl: "Updating Profile")
            AuthClient.updateProfile(ProfileRequest(name: prof.User_code, display_name: titleString == "Change Name" ? self.textField.text! : prof.Fname, email: titleString == "Change Name" ? prof.Email : self.textField.text!)) { [self] result in
                if var response = result {
                    response.CountryCode = prof.CountryCode
                    response.Isd_code = prof.Isd_code
                    Login.storeProfileData(response)
                    if titleString == "Change Name" {
                        PromptVManager.present(self, verifyMessage: "Your name is Successfully Changed", isUserStory: true)
                    } else {
                        PromptVManager.present(self, verifyMessage: "Your Email ID is Successfully Changed", isUserStory: true)
                    }
                }
                Core.HideProgress(self)
            }
        } else {
            Snackbar.showAlertMessage("No Profile data found!")
        }
    }
    
    
    @IBAction func tapOnSubmit(_ sender: Any) {
        if !Reachability.isConnectedToNetwork() {
            Snackbar.showNoInternetMessage()
            return
        }
        if titleString == "Change Name" {
            if textField.text!.isBlank {
                Snackbar.showAlertMessage("Please enter valid name!")
                return
            }
            
            self.updateProfileData()
        } else {
            if textField.text!.isBlank || !textField.text!.isEmail {
                Snackbar.showAlertMessage("Please enter valid email!")
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
