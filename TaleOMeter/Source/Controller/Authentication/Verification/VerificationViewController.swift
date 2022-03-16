//
//  VerificationViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 14/02/22.
//


import UIKit

class VerificationViewController: UIViewController {
    
    // MARK: - Public Properties -
    var mobileNumber = ""
    var countryCode = ""
    var iSDCode = 0

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
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShowNotification (notification: Notification) {
        if self.view.frame.origin.y == 0.0 {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.frame.origin.y -= 100.0
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
    
    @IBAction func tapOnResendOTP(_ sender: Any) {
        if !Reachability.isConnectedToNetwork() {
            Toast.show()
            return
        }
        Core.ShowProgress(self, detailLbl: "Sending OTP...")
        AuthClient.login(LoginRequest(mobile: self.mobileNumber)) { status in
            Core.HideProgress(self)
        }
    }
    
    @IBAction func tapOnSubmit(_ sender: Any) {
        if !Reachability.isConnectedToNetwork() {
            Toast.show()
            return
        }
        if self.otp1TextField.text!.isEmpty || self.otp2TextField.text!.isEmpty || self.otp3TextField.text!.isEmpty ||
            self.otp4TextField.text!.isEmpty {
            Toast.show("Please Enter valid OTP to complete verification!")
            return
        }
        
        let otp = "\(self.otp1TextField.text!)\(self.otp2TextField.text!)\(self.otp3TextField.text!)\(self.otp4TextField.text!)"
        Core.ShowProgress(self, detailLbl: "Verification OTP...")
        AuthClient.verifyOtp(VerificationRequest(mobile: mobileNumber, otp: Int(otp) ?? 0)) { result, status, token, isNewRegister in
            if var response = result, !token.isBlank {
                UserDefaults.standard.set(true, forKey: Constants.UserDefault.IsLogin)
                UserDefaults.standard.set(token, forKey: Constants.UserDefault.AuthTokenStr)
                if isNewRegister {
                    response.StoryBoardName = Constants.Storyboard.auth
                    response.StoryBoardId = "RegisterViewController"
                    self.performSegue(withIdentifier: "register", sender: sender)
                } else {
                    if isOnlyTrivia {
                        Core.push(self, storyboard: Constants.Storyboard.trivia, storyboardId: "TriviaViewController")
                    } else {
                        response.StoryBoardName = Constants.Storyboard.dashboard
                        response.StoryBoardId = "PreferenceViewController"

                        Core.push(self, storyboard: Constants.Storyboard.dashboard, storyboardId: "PreferenceViewController")
                    }
                }
                Login.storeProfileData(response)
            }
            Core.HideProgress(self)
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "register", let veryVC = segue.destination as? RegisterViewController {
            veryVC.countryCode = self.countryCode
            veryVC.iSDCode = self.iSDCode
        }
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
    
    // Set error
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.setError()
    }
}
