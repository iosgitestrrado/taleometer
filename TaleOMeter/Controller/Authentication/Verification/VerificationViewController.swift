//
//  VerificationViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 14/02/22.
//


import UIKit

class VerificationViewController: UIViewController {
    
    // MARK: - Storyboard Outlet / Connection -
    @IBOutlet weak var otp1TextField: UITextField!
    @IBOutlet weak var otp2TextField: UITextField!
    @IBOutlet weak var otp3TextField: UITextField!
    @IBOutlet weak var otp4TextField: UITextField!
    
    
    // MARK: - Lifecycle -
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHideNotification), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboard()
        //self.navigationItem.hidesBackButton = true
        self.otp1TextField.becomeFirstResponder()
    }
    
    @IBAction func changeCharacter(_ sender: UITextField) {
        if sender.text?.utf8.count == 1 {
            switch sender {
            case otp1TextField:
                otp2TextField.becomeFirstResponder()
            case otp2TextField:
                otp3TextField.becomeFirstResponder()
            case otp3TextField:
                otp4TextField.becomeFirstResponder()
            case otp4TextField:
                self.hideKeyboard()
            default:
                break
            }
        } else if sender.text!.isEmpty {
            switch sender {
            case otp4TextField:
                otp3TextField.becomeFirstResponder()
            case otp3TextField:
                otp2TextField.becomeFirstResponder()
            case otp2TextField:
                otp1TextField.becomeFirstResponder()
            default:
                break
            }
        }
    }
    
    @objc func keyboardWillShowNotification (notification: Notification) {
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue, self.view.frame.origin.y == 0.0 {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                let height = frame.cgRectValue.height
                self.view.frame.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height - height)
                        self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc func keyboardDidHideNotification (notification: Notification) {
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue, self.view.frame.origin.y != 0.0 {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                let height = frame.cgRectValue.height
                self.view.frame.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height + height)
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        }
    }
    
    @IBAction func tapOnResendOTP(_ sender: Any) {
    }
    
    @IBAction func tapOnSubmit(_ sender: Any) {
        self.performSegue(withIdentifier: "register", sender: sender)
    }
}

extension VerificationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.utf8.count == 1 && !string.isEmpty {
            return false
        }
        return true
    }
}
