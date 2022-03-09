//
//  LoginViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 14/02/22.
//


import UIKit
import CoreTelephony

class LoginViewController: UIViewController {
    
    // MARK: - Weak Properties -
    @IBOutlet weak var countryCodeLbl: UILabel!
    @IBOutlet weak var mobileNumberTxt: UITextField!
    
    // MARK: - Private Properties -
    private var countryModel: Country = Country()
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboard()
        //self.mobileNumberTxt.becomeFirstResponder()
        setDefaultCountry()
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
    
    @IBAction func tapOnSubmit(_ sender: Any) {
        if !Reachability.isConnectedToNetwork() {
            Snackbar.showNoInternetMessage()
            return
        }
        if !self.mobileNumberTxt.text!.isPhoneNumber {
            Snackbar.showAlertMessage("Please Enter correct Mobile Number!")
            return
        }
       // Core.push(self, storyboard: Storyboard.auth, storyboardId: "VerificationViewController")
        Core.ShowProgress(self, detailLbl: "Sending OTP...")
        AuthClient.login(LoginRequest(mobile: self.mobileNumberTxt.text!)) { status in
            Core.HideProgress(self)
            if status {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateUserData"), object: nil)
                self.performSegue(withIdentifier: "verification", sender: sender)
            }
        }
    }
    
    @IBAction func tapOnTermsAndCond(_ sender: Any) {
        self.performSegue(withIdentifier: "termsAndCondition", sender: sender)
    }
    
    // MARK: - Country
    private func setDefaultCountry() {
        //let carrier = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.first?.value, let code = carrier.isoCountryCode
        if let code = NSLocale.current.regionCode  {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_US").displayName(forKey: NSLocale.Key.identifier, value: id)
            
            let locale = NSLocale.init(localeIdentifier: id)
            let countryCode = locale.object(forKey: NSLocale.Key.countryCode)
            
            if name != nil {
                let model = Country()
                model.name = name
                model.countryCode = countryCode as? String
               // model.currencyCode = currencyCode as? String
               // model.currencySymbol = currencySymbol as? String
                model.flag = String.flag(for: code)
                if NSLocale().extensionCode(countryCode: model.countryCode) != nil {
                    model.extensionCode = "+\(NSLocale().extensionCode(countryCode: model.countryCode) ?? "")"
                }
                countryModel = model
                self.countryCodeLbl.text = "\(model.flag!) \(model.extensionCode!)"
            }
        }
    }
    
    @IBAction func tapOnCountry(_ sender: Any) {
        let myobject = UIStoryboard(name: Constants.Storyboard.auth, bundle: nil).instantiateViewController(withIdentifier: "CountryViewController") as! CountryViewController
        myobject.delegate = self
        self.navigationController?.present(myobject, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "verification", let veryVC = segue.destination as? VerificationViewController {
            veryVC.mobileNumber = self.mobileNumberTxt.text!
            if let cCode = self.countryModel.countryCode {
                veryVC.countryCode = cCode
            }
            if let exCode = self.countryModel.extensionCode, let isdCode = Int(exCode.replacingOccurrences(of: "+", with: "")) {
                veryVC.iSDCode = isdCode
            }
        }
    }
}

// MARK: - Country selection delegate
extension LoginViewController: CountryCodeDelegate {
    func selectedCountryCode(country: Country) {
        self.countryModel = country
        self.countryCodeLbl.text = "\(country.flag!) \(country.extensionCode!)"
       // print("Country: \(country.flag!) \(country.extensionCode!)")
    }
}

// MARK: - Textfield delegate
extension LoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !string.isEmpty && textField.text!.utf8.count >= 10 {
            return "\(self.countryModel.extensionCode!)\(textField.text!)".isPhoneNumber
        }
        return string.isBlank || string.isNumber
    }
}
