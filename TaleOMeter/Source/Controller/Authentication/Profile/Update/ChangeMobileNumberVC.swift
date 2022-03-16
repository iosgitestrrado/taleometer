//
//  ChangeMobileNumberVC.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit



class ChangeMobileNumberVC: UIViewController {
    
    // MARK: - Weak Property -
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var mobileTextField: UITextField!
    
    // Making this a weak variable, so that it won't create a strong reference cycle
    weak var profileDelegate: ProfileEditDelegate? = nil

    // MARK: - Public Properties -
    var fieldValue = ""
    var countryCodeVal = ""
    
    // MARK: - Private Properties -
    private var countryModel: Country = Country()
    private var profileData: ProfileData?
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let pfData = Login.getProfileData() {
            profileData = pfData
        }
        
        self.hideKeyboard()
//        let contact = fieldValue.components(separatedBy: " ")
//        if contact.count > 1 {
//            self.mobileTextField.text = contact[1]
//        }
        if let pfData = profileData {
            countryCodeVal = pfData.Country_code.isBlank ? "IN" : pfData.Country_code
            self.mobileTextField.text = pfData.Phone
        }
        setDefaultCountry()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: false)
    }
    
    @IBAction func tapOnCountry(_ sender: Any) {
        let myobject = UIStoryboard(name: Constants.Storyboard.auth, bundle: nil).instantiateViewController(withIdentifier: "CountryViewController") as! CountryViewController
        myobject.delegate = self
        self.navigationController?.present(myobject, animated: true, completion: nil)
    }
    
    @IBAction func tapOnSubmit(_ sender: Any) {
        if !Reachability.isConnectedToNetwork() {
            Toast.show()
            return
        }
        if self.mobileTextField.text!.isBlank {
            Validator.showRequiredError(self.mobileTextField)
            return
        }
        if !self.mobileTextField.text!.isPhoneNumber {
            Validator.showError(self.mobileTextField, message: "Invalid phone number")
            return
        }
       // Core.push(self, storyboard: Storyboard.auth, storyboardId: "VerificationViewController")
        self.sendOpt()
    }
    
    private func sendOpt() {
        if !Reachability.isConnectedToNetwork() {
            Toast.show()
            return
        }
        Core.ShowProgress(self, detailLbl: "Sending OTP")
        AuthClient.sendProfileOtp(LoginRequest(mobile: self.mobileTextField.text!, isd_code: self.countryModel.extensionCode ?? "91", country_code: self.countryModel.countryCode ?? "IN")) { status in
            if status {
                self.performSegue(withIdentifier: "verification", sender: self)
            }
            Core.HideProgress(self)
        }
    }
    
    // MARK: - Country
    private func setDefaultCountry() {
        //let carrier = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.first?.value, let code = carrier.isoCountryCode
        
        if !countryCodeVal.isBlank {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: countryCodeVal])
            let name = NSLocale(localeIdentifier: "en_US").displayName(forKey: NSLocale.Key.identifier, value: id)
            
            let locale = NSLocale.init(localeIdentifier: id)
            let countryCode = locale.object(forKey: NSLocale.Key.countryCode)
           
            if name != nil {
                let model = Country()
                model.name = name
                model.countryCode = countryCode as? String
               // model.currencyCode = currencyCode as? String
               // model.currencySymbol = currencySymbol as? String
                //model.flag = String.flag(for: countryCodeVal)
                if NSLocale().extensionCode(countryCode: model.countryCode) != nil {
                    model.extensionCode = "+\(NSLocale().extensionCode(countryCode: model.countryCode) ?? "")"
                }
                countryModel = model
                self.countryLabel.text = model.extensionCode!
            }
        } else if let code = NSLocale.current.regionCode  {
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
                //model.flag = String.flag(for: code)
                if NSLocale().extensionCode(countryCode: model.countryCode) != nil {
                    model.extensionCode = "+\(NSLocale().extensionCode(countryCode: model.countryCode) ?? "")"
                }
                countryModel = model
                self.countryLabel.text = model.extensionCode!
            }
        }
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "verification", let veriVC = segue.destination as? VerificationProfileVC {
            veriVC.profileDelegate = self.profileDelegate
            if let mobile = self.mobileTextField.text, let countryCode = self.countryModel.countryCode {
                veriVC.mobileNumber = mobile
                veriVC.countryCode = countryCode
            }
        }
    }
}


// MARK: - Country selection delegate
extension ChangeMobileNumberVC: CountryCodeDelegate {
    func selectedCountryCode(country: Country) {
        self.countryModel = country
        self.countryLabel.text = country.extensionCode
       // print("Country: \(country.flag!) \(country.extensionCode!)")
    }
}

// MARK: - Textfield delegate
extension ChangeMobileNumberVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return string.isBlank || string.isNumber
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.setError()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text!.isBlank {
            Validator.showRequiredError(textField)
            return
        }
        if !textField.text!.isPhoneNumber {
            Validator.showError(textField, message: "Invalid phone number")
            return
        }
    }
}

// MARK: - ProfileEditDelegate -
extension ChangeMobileNumberVC: ProfileEditDelegate  {

    func didChangeProfileData(_ data: String, code: String) {
        
    }
}
