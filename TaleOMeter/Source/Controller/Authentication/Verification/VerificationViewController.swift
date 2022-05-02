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
    var countryCode = "IN"
    var iSDCode = 91

    // MARK: - Weak Properties -
    @IBOutlet weak var otp1TextField: CustomTextField!
    @IBOutlet weak var otp2TextField: CustomTextField!
    @IBOutlet weak var otp3TextField: CustomTextField!
    @IBOutlet weak var otp4TextField: CustomTextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabel1: UILabel!
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboard()
        //self.navigationItem.hidesBackButton = true
        otp1TextField.backSpaceDelegate = self
        otp2TextField.backSpaceDelegate = self
        otp3TextField.backSpaceDelegate = self
        otp4TextField.backSpaceDelegate = self
        
        otp1TextField.textContentType = .oneTimeCode
        otp1TextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        titleLabel.addUnderline()
        
//        let titleString = NSMutableAttributedString(string: "Welcome To tale'o'meter\n           Your Phone Number.")
//        let font36 = [ NSAttributedString.Key.font: UIFont(name: "CommutersSans-Regular", size: 34) ]
//        let font22 = [ NSAttributedString.Key.font: UIFont(name: "CommutersSans-Regular", size: 20) ]
//
//        let rangeTitle1 = NSRange(location: 0, length: 23)
//        let rangeTitle2 = NSRange(location: 23, length: 30)
//
//        titleString.addAttributes(font36 as [NSAttributedString.Key : Any], range: rangeTitle1)
//        titleString.addAttributes(font22 as [NSAttributedString.Key : Any], range: rangeTitle2)
//
//        titleLabel1.attributedText = titleString
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        otp1TextField.becomeFirstResponder()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.textContentType == UITextContentType.oneTimeCode {
            //here split the text to your four text fields
            if let otpCode = textField.text, otpCode.count > 3 {
                otp1TextField.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 0)])
                otp2TextField.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 1)])
                otp3TextField.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 2)])
                otp4TextField.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 3)])
            }
        }
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
            Core.noInternet(self)
            return
        }
        Core.ShowProgress(self, detailLbl: "Sending OTP...")
        AuthClient.login(LoginRequest(mobile: self.mobileNumber, isd_code: "\(self.iSDCode)", country_code: self.countryCode)) { status in
            Core.HideProgress(self)
        }
    }
    
    @IBAction func tapOnSubmit(_ sender: Any) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        if self.otp1TextField.text!.isEmpty || self.otp2TextField.text!.isEmpty || self.otp3TextField.text!.isEmpty ||
            self.otp4TextField.text!.isEmpty {
            Toast.show("Please Enter valid OTP to complete verification!")
            return
        }
        
        let otp = "\(self.otp1TextField.text!)\(self.otp2TextField.text!)\(self.otp3TextField.text!)\(self.otp4TextField.text!)"
        Core.ShowProgress(self, detailLbl: "Verification OTP...")
        AuthClient.verifyOtp(VerificationRequest(mobile: mobileNumber, otp: Int(otp) ?? 0, isd_code: "\(iSDCode)", country_code: countryCode)) { result, status, token, isNewRegister in
            if var response = result, !token.isBlank {
                UserDefaults.standard.set(true, forKey: Constants.UserDefault.IsLogin)
                UserDefaults.standard.set(token, forKey: Constants.UserDefault.AuthTokenStr)
                if isNewRegister {
                    response.StoryBoardName = Constants.Storyboard.auth
                    response.StoryBoardId = "RegisterViewController"
                } else {
                    if !isOnlyTrivia {
                        response.StoryBoardName = Constants.Storyboard.dashboard
                        response.StoryBoardId = "PreferenceViewController"
                    }
                }
                Login.storeProfileData(response)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateUserData"), object: nil)
                self.setNotificationToken(isNewRegister)
            } else {
                Core.HideProgress(self)
            }
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

// MARK: Set notification token
extension VerificationViewController {
    private func setNotificationToken(_ isNewRegister: Bool) {
        if let nToken = UserDefaults.standard.string(forKey: Constants.UserDefault.FCMTokenStr) {
            AuthClient.updateNotificationToken(NotificationRequest(token: nToken)) { status in
                if isNewRegister {
                    self.performSegue(withIdentifier: "register", sender: self)
                } else {
                    if isOnlyTrivia {
                        Core.push(self, storyboard: Constants.Storyboard.trivia, storyboardId: "TriviaViewController")
                    } else {
                        Core.push(self, storyboard: Constants.Storyboard.dashboard, storyboardId: "PreferenceViewController")
                    }
                }
                Core.HideProgress(self)
            }
        } else {
            if isNewRegister {
                self.performSegue(withIdentifier: "register", sender: self)
            } else {
                if isOnlyTrivia {
                    Core.push(self, storyboard: Constants.Storyboard.trivia, storyboardId: "TriviaViewController")
                } else {
                    Core.push(self, storyboard: Constants.Storyboard.dashboard, storyboardId: "PreferenceViewController")
                }
            }
            Core.HideProgress(self)
        }
    }
}

extension VerificationViewController: UITextFieldDelegate, BackSpaceDelegate {
    
    func deleteBackWord(textField: CustomTextField) {
        /// do your stuff here. That means resign or become first responder your expected textfield.
        switch textField {
        case otp2TextField:
            otp2TextField.text = ""
            otp1TextField.becomeFirstResponder()
            return
        case otp3TextField:
            otp3TextField.text = ""
            otp2TextField.becomeFirstResponder()
            return
        case otp4TextField:
            otp4TextField.text = ""
            otp3TextField.becomeFirstResponder()
            return
        default:
            otp1TextField.text = ""
            return
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92) {
                switch textField {
                case otp2TextField:
                    otp2TextField.text = ""
                    //otp1TextField.becomeFirstResponder()
                    return false
                case otp3TextField:
                    otp3TextField.text = ""
                    //otp2TextField.becomeFirstResponder()
                    return false
                case otp4TextField:
                    otp4TextField.text = ""
                    //otp3TextField.becomeFirstResponder()
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
