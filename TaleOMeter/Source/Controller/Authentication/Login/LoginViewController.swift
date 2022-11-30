//
//  LoginViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 14/02/22.
//


import UIKit
import CoreTelephony
import GoogleSignIn
import FacebookLogin
import FirebaseAnalytics
import SwiftyJSON

class LoginViewController: UIViewController {
    
    // MARK: - Weak Properties -
    @IBOutlet weak var countryCodeLbl: UILabel!
    @IBOutlet weak var mobileNumberTxt: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabel1: UILabel!

    // MARK: - Private Properties -
    private var countryModel: Country = Country()
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboard()
        //self.mobileNumberTxt.becomeFirstResponder()
        setDefaultCountry()
        //loginButton.permissions = ["public_profile", "email"]

//        titleLabel.addUnderline()
        
//        let titleString = NSMutableAttributedString(string: "Welcome To tale'o'meter\nSign up To Keep Hearing Amazing")
//        let font36 = [ NSAttributedString.Key.font: UIFont(name: "CommutersSans-Bold", size: 25) ]
//        let font22 = [ NSAttributedString.Key.font: UIFont(name: "CommutersSans-Bold", size: 16) ]
//        
//        let rangeTitle1 = NSRange(location: 0, length: 23)
//        let rangeTitle2 = NSRange(location: 23, length: 55 - 23)
//        
//        titleString.addAttributes(font36 as [NSAttributedString.Key : Any], range: rangeTitle1)
//        titleString.addAttributes(font22 as [NSAttributedString.Key : Any], range: rangeTitle2)
//        
//        titleLabel1.attributedText = titleString
        if let player = AudioPlayManager.shared.playerAV, player.isPlaying {
            player.pause()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: isOnlyTrivia, isRightViewEnabled: false)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            self.sideMenuController!.toggleRightView(animated: false)
        }
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
        if let textContainer = window.viewWithTag(9998) {
            textContainer.removeFromSuperview()
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
    
    @IBAction func tapOnSubmit(_ sender: UIButton) {
        if sender.tag == 1 { //Custom Login
            if !Reachability.isConnectedToNetwork() {
                Core.noInternet(self)
                return
            }
            if self.mobileNumberTxt.text!.isBlank {
                Validator.showRequiredError(self.mobileNumberTxt)
                return
            }
            if !self.mobileNumberTxt.text!.isPhoneNumber {
                Validator.showError(self.mobileNumberTxt, message: "Invalid phone number")
                return
            }
           // Core.push(self, storyboard: Storyboard.auth, storyboardId: "VerificationViewController")
            Core.ShowProgress(self, detailLbl: "Sending OTP...")
            AuthClient.login(LoginRequest(mobile: self.mobileNumberTxt.text!, isd_code: countryModel.extensionCode ?? "+91", country_code: countryModel.countryCode ?? "IN")) { status in
                Core.HideProgress(self)
                if status {
    //                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateUserData"), object: nil)
                    self.performSegue(withIdentifier: "verification", sender: sender)
                }
            }
        } else if sender.tag == 2 { //Facebook Login
            Core.ShowProgress(self, detailLbl: "Google SignIn...")
            let fbLoginManager : LoginManager = LoginManager()
            fbLoginManager.logIn(permissions: ["email"], from: self) { result, error in
                if error == nil {
                    let fbloginresult : LoginManagerLoginResult = result!
                    // if user cancel the login
                    if (result?.isCancelled)! {
                        self.showToast(message: "Cancelled by user")
                        Core.HideProgress(self)
                        return
                    }
                    if fbloginresult.grantedPermissions.contains("email") {
                        self.getFBUserData()
                    } else {
                        self.showToast(message: "Facebook login failed")
                        Core.HideProgress(self)
                    }
                }
            }

        } else if sender.tag == 3 { // Google Login
            Core.ShowProgress(self, detailLbl: "Google SignIn...")
            let signInConfig = GIDConfiguration(clientID: Constants.GOOGLE_IOS_CLIENT_ID)
            GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
                if error == nil, let signInUser = user {
                    self.googleSiginAPI(signInUser)
                } else if let message = error?.localizedDescription {
                    Toast.show(message)
                    Core.HideProgress(self)
                } else {
                    Core.HideProgress(self)
                }
            }
        }
    }
    
    func getFBUserData(){
        if AccessToken.current != nil {
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if error == nil, let dicObject = result as? Dictionary<String, Any> {
                    //everything works print the user data
                    self.facebookSiginAPI(FBLoginModel(JSON(dicObject)))
                } else {
                    self.showToast(message: "Facebook login failed")
                    Core.HideProgress(self)
                }
            })
        }
    }
    
    @IBAction func tapOnTermsAndCond(_ sender: Any) {
        self.performSegue(withIdentifier: "termsAndCondition", sender: sender)
    }
    
    // MARK: - Country
    private func setDefaultCountry() {
        //let carrier = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.first?.value, let code = carrier.isoCountryCode
        //if let code = NSLocale.current.regionCode  {
            //let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            //let name = NSLocale(localeIdentifier: "en_US").displayName(forKey: NSLocale.Key.identifier, value: id)
            
            //let locale = NSLocale.init(localeIdentifier: id)
            //let countryCode = "IN"//locale.object(forKey: NSLocale.Key.countryCode)
            
            //if name != nil {
                let model = Country()
                model.name = "India"
                model.countryCode = "IN"
               // model.currencyCode = currencyCode as? String
               // model.currencySymbol = currencySymbol as? String
               //model.flag = String.flag(for: code)
                if NSLocale().extensionCode(countryCode: model.countryCode) != nil {
                    model.extensionCode = "+\(NSLocale().extensionCode(countryCode: model.countryCode) ?? "")"
                }
                countryModel = model
                self.countryCodeLbl.text = model.extensionCode!
            //}
        //}
    }
    
    @IBAction func tapOnCountry(_ sender: Any) {
        let myobject = UIStoryboard(name: Constants.Storyboard.auth, bundle: nil).instantiateViewController(withIdentifier: "CountryViewController") as! CountryViewController
        myobject.delegate = self
        self.navigationController?.pushViewController(myobject, animated: true)
        //self.navigationController?.present(myobject, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "verification", let veryVC = segue.destination as? VerificationViewController {
            veryVC.mobileNumber = self.mobileNumberTxt.text!
            veryVC.countryCode = "IN"
            if let cCode = self.countryModel.countryCode {
                veryVC.countryCode = cCode
            }
            veryVC.iSDCode = 91
            if let isdCode = self.countryModel.extensionCode {
                veryVC.iSDCode = Int(isdCode.replacingOccurrences(of: "+", with: "")) ?? 91
            }
//            if let exCode = self.countryModel.extensionCode, let isdCode = Int(exCode.replacingOccurrences(of: "+", with: "")) {
//                veryVC.iSDCode = isdCode
//            }
        }
    }
}

// MARK: - API Calls
extension LoginViewController {
    
    private func facebookSiginAPI(_ signInUser: FBLoginModel) {
        AuthClient.socialLogin(SocialLoginRequest(social_media: "facebook", login_id: signInUser.Id, fname: signInUser.Name, email: signInUser.Email, avatar: signInUser.ProfilePicture)) { profileData, status, token, isNewRegister in
            if var response = profileData, !token.isBlank {
                Analytics.logEvent(AnalyticsEventLogin, parameters: [
                  AnalyticsParameterItemID: "id-facebookemail",
                  AnalyticsParameterItemName: signInUser.Email,
                  AnalyticsParameterContentType: "cont",
                ])
                UserDefaults.standard.set(true, forKey: Constants.UserDefault.IsLogin)
                UserDefaults.standard.set(token, forKey: Constants.UserDefault.AuthTokenStr)
                if isNewRegister {
                    response.StoryBoardName = Constants.Storyboard.auth
                    response.StoryBoardId = "RegisterViewController"
                } else if !isOnlyTrivia && !response.Has_preference {
                    response.StoryBoardName = Constants.Storyboard.dashboard
                    response.StoryBoardId = "PreferenceViewController"
                }
                Login.storeProfileData(response)
                self.setNotificationToken(isNewRegister, hasPreference: response.Has_preference)
            } else {
                Core.HideProgress(self)
            }
        }
    }
    
    private func googleSiginAPI(_ signInUser: GIDGoogleUser) {
        var imageURLString = ""
        if signInUser.profile?.hasImage ?? false {
            let imageURL = signInUser.profile?.imageURL(withDimension: 200)
            imageURLString = imageURL?.absoluteString ?? ""
        }
        
        AuthClient.socialLogin(SocialLoginRequest(social_media: "google", login_id: signInUser.userID ?? "", fname: signInUser.profile?.name ?? "", email: signInUser.profile?.email ?? "", avatar: imageURLString)) { profileData, status, token, isNewRegister in
            if var response = profileData, !token.isBlank {
                Analytics.logEvent(AnalyticsEventLogin, parameters: [
                  AnalyticsParameterItemID: "id-googleemail",
                  AnalyticsParameterItemName: signInUser.profile?.email ?? "",
                  AnalyticsParameterContentType: "cont",
                ])
                UserDefaults.standard.set(true, forKey: Constants.UserDefault.IsLogin)
                UserDefaults.standard.set(token, forKey: Constants.UserDefault.AuthTokenStr)
                if isNewRegister {
                    response.StoryBoardName = Constants.Storyboard.auth
                    response.StoryBoardId = "RegisterViewController"
                } else if !isOnlyTrivia && !response.Has_preference {
                    response.StoryBoardName = Constants.Storyboard.dashboard
                    response.StoryBoardId = "PreferenceViewController"
                }
                Login.storeProfileData(response)
                self.setNotificationToken(isNewRegister, hasPreference: response.Has_preference)
            } else {
                Core.HideProgress(self)
            }
        }
    }
    
    private func setNotificationToken(_ isNewRegister: Bool, hasPreference: Bool) {
        if let nToken = UserDefaults.standard.string(forKey: Constants.UserDefault.FCMTokenStr) {
            AuthClient.updateNotificationToken(NotificationRequest(token: nToken)) { status in
                if isNewRegister {
                    self.performSegue(withIdentifier: "register", sender: self)
                } else {
                    if isOnlyTrivia {
                        Core.push(self, storyboard: Constants.Storyboard.trivia, storyboardId: "TriviaViewController")
                    } else if !hasPreference {
                        Core.push(self, storyboard: Constants.Storyboard.dashboard, storyboardId: "PreferenceViewController")
                    } else {
                        Core.push(self, storyboard: Constants.Storyboard.dashboard, storyboardId: "DashboardViewController")
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
                } else if !hasPreference {
                    Core.push(self, storyboard: Constants.Storyboard.dashboard, storyboardId: "PreferenceViewController")
                } else {
                    Core.push(self, storyboard: Constants.Storyboard.dashboard, storyboardId: "DashboardViewController")
                }
            }
            Core.HideProgress(self)
        }
    }
}

// MARK: - Country selection delegate
extension LoginViewController: CountryCodeDelegate {
    func selectedCountryCode(country: Country) {
        self.countryModel = country
        self.countryCodeLbl.text = country.extensionCode!
       // print("Country: \(country.flag!) \(country.extensionCode!)")
    }
}

// MARK: - Textfield delegate
extension LoginViewController: UITextFieldDelegate {
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
            Validator.showError(self.mobileNumberTxt, message: "Invalid phone number")
            return
        }
    }
}
