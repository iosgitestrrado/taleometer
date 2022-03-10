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
    private var profileData: ProfileData?
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setProfileData()
        if let imgData = profileData?.ImageData, let img = UIImage(data: imgData) {
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
    
    private func setProfileData() {
        
        if let pfData = Login.getProfileData() {
            profileData = pfData
        }
        
        let name = profileData?.Fname ?? ""
        let mobile = "+\(profileData?.Isd_code ?? 0) \(profileData?.Phone ?? "")"
        let email = profileData?.Email ?? ""
        
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
            guard let myobject = UIStoryboard(name: Constants.Storyboard.auth, bundle: nil).instantiateViewController(withIdentifier: "ProfileEditViewController") as? ProfileEditViewController else { break }
            myobject.titleString = "Change Name"
            myobject.fieldValue = profileData?.Fname ?? ""
            myobject.profileDelegate = self
            self.navigationController?.pushViewController(myobject, animated: true)
            break
        case 2:
            //Mobile Number
            guard let myobject = UIStoryboard(name: Constants.Storyboard.auth, bundle: nil).instantiateViewController(withIdentifier: "ChangeMobileNumberVC") as? ChangeMobileNumberVC else { break }
            
            myobject.fieldValue = "+\(profileData?.Isd_code ?? 0) \(profileData?.Phone ?? "")"
            myobject.countryCodeVal = profileData?.CountryCode ?? "IN"
            myobject.profileDelegate = self
            self.navigationController?.pushViewController(myobject, animated: true)
            break
        case 3:
            //Email Id
            guard let myobject = UIStoryboard(name: Constants.Storyboard.auth, bundle: nil).instantiateViewController(withIdentifier: "ProfileEditViewController") as? ProfileEditViewController else { break }
            myobject.titleString = "Change Email ID"
            myobject.fieldValue = profileData?.Email ?? ""
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
                self.profileImage.image = defaultImage
                if let imgData = self.profileImage.image?.pngData() {
                    self.uploadProfileImage(imgData)
                }
            }))
            self.present(alert, animated: true, completion: nil)
            break
        }
    }
    
    private func uploadProfileImage(_ imageData: Data) {
        var imgData = imageData
        Core.ShowProgress(self, detailLbl: "Uploading Profile Picture...")
        if Double(imgData.count) / 1000.0 > 2048.0 {
            let imageis = UIImage(data: imgData)
            imgData = imageis!.jpegData(compressionQuality: 0.5)!
        }
        if Double(imgData.count) / 1000.0 > 2048.0 {
            let imageis = UIImage(data: imgData)
            imgData = imageis!.jpegData(compressionQuality: 0.5)!
        }
        AuthClient.updateProfilePicture(imgData) { result in
            if var response = result {
                response.ImageData = imgData
                response.CountryCode = self.profileData?.CountryCode ?? "IN"
                self.profileData = response
                Login.storeProfileData(response)
            }
            Core.HideProgress(self)
            
        }
    }
    
    private func updateProfileDetails(_ name: String, email: String) {
        Core.ShowProgress(self, detailLbl: "Udpating profile details...")
        var profRequest = ProfileRequest()
        if !name.isBlank {
            profRequest.name = name
        } else {
            profRequest.name = self.profileData?.Fname ?? ""
        }
        
        if !email.isBlank {
            profRequest.email = email
        } else {
            profRequest.email = self.profileData?.Email ?? ""
        }
        
        AuthClient.updateProfile(profRequest) { result in
            if var response = result {
                response.ImageData = self.profileData?.ImageData ?? Data()
                response.CountryCode = self.profileData?.CountryCode ?? "IN"
                self.profileData = response
                Login.storeProfileData(response)
                self.setProfileData()
            }
            Core.HideProgress(self)
            
        }
    }
}

// MARK: - UIImagePickerControllerDelegate -
extension ProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate  {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.profileImage.image = image
        }
        
        if let imgData = self.profileImage.image?.pngData() {
            uploadProfileImage(imgData)
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
            self.updateProfileDetails(data, email: "")
            break
        case 2:
            //Mobile Number
//            self.setProfileData("", mobile: data, email: "")
//            UserDefaults.standard.set(data, forKey: "ProfileMobile")
//            UserDefaults.standard.set(code, forKey: "CountryCode")
            break
        default:
            //Email Id
            self.updateProfileDetails("", email: data)
            break
        }
    }
}
