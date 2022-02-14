//
//  LoginViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 14/02/22.
//


import UIKit
import CoreTelephony

class LoginViewController: UIViewController {
    
    // MARK: - Storyboard Outlet / Connection -
    @IBOutlet weak var countryCodeLbl: UILabel!
    @IBOutlet weak var mobileNumberTxt: UITextField!
    
    fileprivate var countryModel: Country = Country()
    
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
        self.navigationItem.hidesBackButton = true
        //self.mobileNumberTxt.becomeFirstResponder()
        setDefaultCountry()
    }
    
    @objc func keyboardWillShowNotification (notification: Notification) {
        if self.view.frame.origin.y == 0.0 {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.frame.origin.y -= 100.0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc func keyboardDidHideNotification (notification: Notification) {
        if self.view.frame.origin.y != 0.0 {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                self.view.frame.origin.y = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @IBAction func tapOnSubmit(_ sender: Any) {
        self.performSegue(withIdentifier: "verification", sender: sender)
    }
    
    
    @IBAction func tapOnTermsAndCond(_ sender: Any) {
        
    }
    
    // MARK: - Country
    func setDefaultCountry() {
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
                print("Default Country: \(model.flag!) \(model.extensionCode!)")
            }
        }
    }
    
    @IBAction func tapOnCountry(_ sender: Any) {
        let myobject = UIStoryboard(name: Storyboard.auth, bundle: nil).instantiateViewController(withIdentifier: "CountryViewController") as! CountryViewController
        myobject.delegate = self
        self.navigationController?.present(myobject, animated: true, completion: nil)
    }
}

// MARK: - Country selection delegate
extension LoginViewController: CountryCodeDelegate {
    func selectedCountryCode(country: Country) {
        self.countryModel = country
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
