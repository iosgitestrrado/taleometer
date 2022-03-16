//
//  RegisterViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 14/02/22.
//

import UIKit

class RegisterViewController: UIViewController {
    
    // MARK: - Weak Properties -
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var displayNameText: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    // MARK: - Public Properties -
    var countryCode = ""
    var iSDCode = 0
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboard()
        //self.navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShowNotification (notification: Notification) {
        if self.view.frame.origin.y == 0.0 {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.frame.origin.y -= 190.0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc private func keyboardWillHideNotification (notification: Notification) {
        if self.view.frame.origin.y != 0.0 {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                self.view.frame.origin.y = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @IBAction func tapOnSubmit(_ sender: Any) {
        if !Reachability.isConnectedToNetwork() {
            Toast.show()
            return
        }
        if displayNameText.text!.isBlank {
            Validator.showRequiredError(displayNameText)
            return
        }
        if !emailTextField.text!.isBlank && !emailTextField.text!.isEmail {
            Validator.showError(emailTextField, message: "Invalid email")
            return
        }
        var profileReq = ProfileRequest()
        if let name = self.nameTextField.text {
            profileReq.name = name
        }
        if let disName = self.displayNameText.text {
            profileReq.display_name = disName
        }
        if let email = self.emailTextField.text {
            profileReq.email = email
        }
        Core.ShowProgress(self, detailLbl: "")
        AuthClient.updateProfile(profileReq) { [self] result in
            if var response = result {
                if isOnlyTrivia {
                    response.StoryBoardName = ""
                    response.StoryBoardId = ""
                    Core.push(self, storyboard: Constants.Storyboard.trivia, storyboardId: "TriviaViewController")
                } else {
                    response.StoryBoardName = Constants.Storyboard.dashboard
                    response.StoryBoardId = "PreferenceViewController"
                    Core.push(self, storyboard: Constants.Storyboard.dashboard, storyboardId: "PreferenceViewController")
                }
                Login.storeProfileData(response)
            }
            Core.HideProgress(self)
        }
    }
}


extension RegisterViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.setError()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == displayNameText && textField.text!.isBlank {
            Validator.showRequiredError(textField)
            return
        }
        if  textField == emailTextField && !textField.text!.isBlank && !textField.text!.isEmail {
            Validator.showError(textField, message: "Invalid email")
            return
        }
    }
}
