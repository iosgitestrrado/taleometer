//
//  VerificationProfileVC.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit

class VerificationProfileVC: UIViewController {

    // MARK: - Weak Property -
    @IBOutlet weak var otp1Text: UITextField!
    @IBOutlet weak var otp2Text: UITextField!
    @IBOutlet weak var otp3Text: UITextField!
    @IBOutlet weak var otp4Text: UITextField!
    
    // Making this a weak variable, so that it won't create a strong reference cycle
    weak var profileDelegate: ProfileEditDelegate? = nil
    public var mobileNumber = ""
    public var countryCode = ""

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: false)
    }
    
    @IBAction func tapOnResend(_ sender: Any) {
        Snackbar.showSuccessMessage("One time password send to your mobile number!")
    }
    
    @IBAction func tapOnSubmit(_ sender: Any) {
        if !Reachability.isConnectedToNetwork() {
            Snackbar.showNoInternetMessage()
            return
        }
        if self.otp1Text.text!.isEmpty || self.otp2Text.text!.isEmpty || self.otp3Text.text!.isEmpty ||
            self.otp4Text.text!.isEmpty{
            Snackbar.showAlertMessage("Please Enter valid OTP to complete verification!")
            return
        }
        PromptVManager.present(self, isAudioView: false, verifyMessage: "Your Mobile Number is Successfully Changed")
    }
}

// MARK: - UITextFieldDelegate -
extension VerificationProfileVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92) {
                switch textField {
                case otp2Text:
                    otp2Text.text = ""
                    otp1Text.becomeFirstResponder()
                    return false
                case otp3Text:
                    otp3Text.text = ""
                    otp2Text.becomeFirstResponder()
                    return false
                case otp4Text:
                    otp4Text.text = ""
                    otp3Text.becomeFirstResponder()
                    return false
                default:
                    otp1Text.text = ""
                    return false
                }
            }
        }
        if string.count <= 0 {
            return true
        }

        switch textField {
        case otp1Text:
            otp1Text.text = string
            otp2Text.becomeFirstResponder()
            return false
        case otp2Text:
            otp2Text.text = string
            otp3Text.becomeFirstResponder()
            return false
        case otp3Text:
            otp3Text.text = string
            otp4Text.becomeFirstResponder()
            return false
        default:
            otp4Text.text = string
            textField.resignFirstResponder()
            return false
        }
    }
}

// MARK: - PromptViewDelegate -
extension VerificationProfileVC: PromptViewDelegate {
    func didActionOnPromptButton(_ tag: Int) {
        //back to profile screen
        if let navControllers = self.navigationController?.children {
            for controller in navControllers {
                if controller is ProfileViewController {
                    if let del = self.profileDelegate {
                        del.didChangeProfileData(mobileNumber,code: countryCode)
                    }
                    self.navigationController?.popToViewController(controller, animated: true)
                }
            }
        }
    }
}

