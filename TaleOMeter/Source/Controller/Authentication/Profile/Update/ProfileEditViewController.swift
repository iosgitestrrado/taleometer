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
    public var titleString = "Change Name"
    public var fieldValue = ""

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if titleString == "Change Name" {
            self.titleLabelL.text = "Enter your name"
            self.textField.placeholder = "Enter your name"
        }
        self.textField.text = fieldValue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = titleString
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: false)
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
            PromptVManager.present(self, verifyMessage: "Your name is Successfully Changed", isUserStory: true)
        } else {
            if textField.text!.isBlank || !textField.text!.isEmail {
                Snackbar.showAlertMessage("Please enter valid email!")
                return
            }
            PromptVManager.present(self, verifyMessage: "Your Email ID is Successfully Changed", isUserStory: true)
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
