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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHideNotification), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShowNotification (notification: Notification) {
        if self.view.frame.origin.y == 0.0 {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.frame.origin.y -= 170.0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc private func keyboardDidHideNotification (notification: Notification) {
        if self.view.frame.origin.y != 0.0 {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                self.view.frame.origin.y = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @IBAction func tapOnSubmit(_ sender: Any) {
        if !Reachability.isConnectedToNetwork() {
            Snackbar.showNoInternetMessage()
            return
        }
        if displayNameText.text!.isBlank {
            Snackbar.showAlertMessage("Please enter valid display name!")
            return
        }
        if !emailTextField.text!.isBlank {
            if emailTextField.text!.isEmail {
                UserDefaults.standard.set(emailTextField.text!, forKey: "ProfileEmail")
            } else {
                Snackbar.showAlertMessage("Please enter valid email!")
                return
            }
        }
        UserDefaults.standard.set(displayNameText.text!, forKey: "ProfileName")
        UserDefaults.standard.set(Storyboard.dashboard, forKey: "storyboardName")
        UserDefaults.standard.set("PreferenceViewController", forKey: "storyboardId")
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateUserData"), object: nil)
        Core.push(self, storyboard: Storyboard.dashboard, storyboardId: "PreferenceViewController")
    }
}
