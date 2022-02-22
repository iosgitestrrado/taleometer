//
//  VerificationViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 14/02/22.
//


import UIKit

class VerificationViewController: UIViewController {
    
    // MARK: - Weak Properties -
    @IBOutlet weak var otp1TextField: UITextField!
    @IBOutlet weak var otp2TextField: UITextField!
    @IBOutlet weak var otp3TextField: UITextField!
    @IBOutlet weak var otp4TextField: UITextField!
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboard()
        //self.navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: true, isRightViewEnabled: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHideNotification), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShowNotification (notification: Notification) {
        if self.view.frame.origin.y == 0.0 {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.frame.origin.y -= 100.0
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
    
    @IBAction func tapOnResendOTP(_ sender: Any) {
        Snackbar.showSuccessMessage("One time password send to your mobile number!")
    }
    
    @IBAction func tapOnSubmit(_ sender: Any) {
        if !Reachability.isConnectedToNetwork() {
            Snackbar.showNoInternetMessage()
            return
        }
        if self.otp1TextField.text!.isEmpty || self.otp2TextField.text!.isEmpty || self.otp3TextField.text!.isEmpty ||
            self.otp4TextField.text!.isEmpty{
            Snackbar.showAlertMessage("Please Enter valid OTP to complete verification!")
            return
        }
        self.performSegue(withIdentifier: "register", sender: sender)
    }
}

extension VerificationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92) {
                switch textField {
                case otp2TextField:
                    otp2TextField.text = ""
                    otp1TextField.becomeFirstResponder()
                    return false
                case otp3TextField:
                    otp3TextField.text = ""
                    otp2TextField.becomeFirstResponder()
                    return false
                case otp4TextField:
                    otp4TextField.text = ""
                    otp3TextField.becomeFirstResponder()
                    return false
                default:
                    otp1TextField.text = ""
                    return false
                }
            }
        }
        if string.count <= 0 {
            return true
        }

        switch textField {
        case otp1TextField:
            otp1TextField.text = string
            otp2TextField.becomeFirstResponder()
            return false
        case otp2TextField:
            otp2TextField.text = string
            otp3TextField.becomeFirstResponder()
            return false
        case otp3TextField:
            otp3TextField.text = string
            otp4TextField.becomeFirstResponder()
            return false
        default:
            otp4TextField.text = string
            textField.resignFirstResponder()
            //self.OTPVerify()
            return false
        }
    }
}
