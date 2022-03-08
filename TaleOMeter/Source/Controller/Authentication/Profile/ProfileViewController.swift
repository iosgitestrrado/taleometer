//
//  ProfileViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit

class ProfileViewController: UIViewController {

    // MARK: - Weak Property -
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    // MARK: - Private Property -
    private let imagePicker = UIImagePickerController()
    private var editIndex = -1
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setProfileData(UserDefaults.standard.string(forKey: "ProfileName") ?? "", mobile: UserDefaults.standard.string(forKey: "ProfileMobile") ?? "", email: UserDefaults.standard.string(forKey: "ProfileEmail") ?? "")
        if let imgData = UserDefaults.standard.object(forKey: "ProfileImage") as? Data, let img = UIImage(data: imgData) {
            self.profileImage.image = img
        }
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true)
        
        //Add footer view and manager current view frame
        FooterManager.addFooter(self)
        if AudioPlayManager.shared.isMiniPlayerActive {
            AudioPlayManager.shared.addMiniPlayer(self)
        }
    }
    
    private func setProfileData(_ name: String, mobile: String, email: String) {
        let pencilAtt = Core.getImageString("pencil")
        let phoneAtt = Core.getImageString("phone")
        let emailAtt = Core.getImageString("email")

        let titleAttText = NSMutableAttributedString(string: "\(name)  ")
        let mobileText = NSMutableAttributedString(string: " \(mobile)  ")
        let emailText = NSMutableAttributedString(string: " \(email)  ")
        
        if !name.isEmpty {
            titleAttText.append(pencilAtt)
            self.titleLabel.attributedText = titleAttText
        }
        
        if !mobile.isEmpty {
            let mobileAttText = phoneAtt
            mobileAttText.append(mobileText)
            mobileAttText.append(pencilAtt)
            self.mobileLabel.attributedText = mobileAttText
        }
        
        if !email.isEmpty {
            let emailAttText = emailAtt
            emailAttText.append(emailText)
            emailAttText.append(pencilAtt)
            self.emailLabel.attributedText = emailAttText
        }
    }
    
    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        self.sideMenuController!.toggleRightView(animated: true)
    }
   
    // MARK: 0 - Image, 1 - Name, 2 - Mobile Number, 3 - Email Id
    @IBAction func tapOnEdit(_ sender: UIButton) {
        editIndex = sender.tag
        switch sender.tag {
        case 1:
            //Name
            guard let myobject = UIStoryboard(name: Storyboard.auth, bundle: nil).instantiateViewController(withIdentifier: "ProfileEditViewController") as? ProfileEditViewController else { break }
            myobject.titleString = "Change Name"
            myobject.fieldValue = UserDefaults.standard.string(forKey: "ProfileName") ?? ""
            myobject.profileDelegate = self
            self.navigationController?.pushViewController(myobject, animated: true)
            break
        case 2:
            //Mobile Number
            guard let myobject = UIStoryboard(name: Storyboard.auth, bundle: nil).instantiateViewController(withIdentifier: "ChangeMobileNumberVC") as? ChangeMobileNumberVC else { break }
            
            myobject.fieldValue = UserDefaults.standard.string(forKey: "ProfileMobile") ?? ""
            myobject.countryCodeVal = UserDefaults.standard.string(forKey: "CountryCode") ?? "IN"
            myobject.profileDelegate = self
            self.navigationController?.pushViewController(myobject, animated: true)
            break
        case 3:
            //Email Id
            guard let myobject = UIStoryboard(name: Storyboard.auth, bundle: nil).instantiateViewController(withIdentifier: "ProfileEditViewController") as? ProfileEditViewController else { break }
            myobject.titleString = "Change Email ID"
            myobject.fieldValue = UserDefaults.standard.string(forKey: "ProfileEmail") ?? ""
            myobject.profileDelegate = self
            self.navigationController?.pushViewController(myobject, animated: true)
            break
        default:
            //Image
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            let alert = UIAlertController(title: "Please Select", message: "", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { result in
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Photo library", style: .default, handler: { result in
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Remove Profile", style: .destructive, handler: { result in
                self.profileImage.image = UIImage(named: "logo")
                if let data = self.profileImage.image?.pngData() {
                    UserDefaults.standard.set(data, forKey: "ProfileImage")
                }
                UserDefaults.standard.synchronize()
                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateUserData"), object: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            break
        }
    }
}

// MARK: - UIImagePickerControllerDelegate -
extension ProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate  {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.profileImage.image = image
        }
        
        if let data = self.profileImage.image?.pngData() {
            UserDefaults.standard.set(data, forKey: "ProfileImage")
        }
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateUserData"), object: nil)
        self.imagePicker.dismiss(animated: true) {
            PromptVManager.present(self, verifyMessage: "Your Profile Image is Successfully Changed", isUserStory: true)
        }
    }
}

// MARK: - ProfileEditDelegate -
extension ProfileViewController: ProfileEditDelegate  {

    func didChangeProfileData(_ data: String, code: String) {
        switch editIndex {
        case 1:
            //Name
            self.setProfileData(data, mobile: "", email: "")
            UserDefaults.standard.set(data, forKey: "ProfileName")
            break
        case 2:
            //Mobile Number
            self.setProfileData("", mobile: data, email: "")
            UserDefaults.standard.set(data, forKey: "ProfileMobile")
            UserDefaults.standard.set(code, forKey: "CountryCode")
            break
        default:
            //Email Id
            self.setProfileData("", mobile: "", email: data)
            UserDefaults.standard.set(data, forKey: "ProfileEmail")
            break
        }
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateUserData"), object: nil)
    }
}
