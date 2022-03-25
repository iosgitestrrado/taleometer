//
//  ProfileViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit
import AVFoundation

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
        self.hideKeyboard()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true)
        
        if !isOnlyTrivia {
            //Add footer view and manager current view frame
            FooterManager.addFooter(self)
            if AudioPlayManager.shared.isMiniPlayerActive {
                AudioPlayManager.shared.addMiniPlayer(self)
            }
        }
        Core.ShowProgress(self, detailLbl: "Getting Profile details...")
        setProfileData()
        if let imgData = profileData?.ImageData, let img = UIImage(data: imgData) {
            self.profileImage.image = img
        }
        Core.HideProgress(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sideMenuController!.toggleRightView(animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
            myobject.countryCodeVal = profileData?.Country_code ?? "IN"
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
                if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Toast.show("Camera not supported")
                    return
                }
                
                if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                    DispatchQueue.main.async {
                        self.imagePicker.sourceType = .camera
                        self.present(self.imagePicker, animated: true, completion: nil)
                    }
                } else {
                    AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                        if granted {
                            DispatchQueue.main.async {
                                self.imagePicker.sourceType = .camera
                                self.present(self.imagePicker, animated: true, completion: nil)
                            }
                        }
                    })
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Photo library", style: .default, handler: { result in
                if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    Toast.show("Photo library not supported")
                    return
                }
                
                if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                    DispatchQueue.main.async {
                        self.imagePicker.sourceType = .photoLibrary
                        self.present(self.imagePicker, animated: true, completion: nil)
                    }
                } else {
                    AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                        if granted {
                            DispatchQueue.main.async {
                                self.imagePicker.sourceType = .photoLibrary
                                self.present(self.imagePicker, animated: true, completion: nil)
                            }
                        }
                    })
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Remove Profile Picture", style: .destructive, handler: { result in
                Core.ShowProgress(self, detailLbl: "Uploading Profile Picture...")
                if let imgData = defaultImage.pngData() {
                    self.uploadProfileImage(imgData, image: defaultImage)
                } else {
                    Core.HideProgress(self)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            break
        }
    }
    
    private func uploadProfileImage(_ imageData: Data, image: UIImage) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        var imgData = imageData
        if Double(imgData.count) / 1000.0 > 2048.0 {
            let imageis = UIImage(data: imgData)
            imgData = imageis!.jpegData(compressionQuality: 0.5)!
        }
        if Double(imgData.count) / 1000.0 > 2048.0 {
            let imageis = UIImage(data: imgData)
            imgData = imageis!.jpegData(compressionQuality: 0.5)!
        }
        AuthClient.updateProfilePicture(imgData) { result in
            if let response = result {
                self.profileData = response
                Login.storeProfileData(response)
                self.profileImage.image = image
                PromptVManager.present(self, verifyMessage: "Your Profile Image is Successfully Changed", isUserStory: true)
            }
            Core.HideProgress(self)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate -
extension ProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate  {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.imagePicker.dismiss(animated: true) { [self] in
            Core.ShowProgress(self, detailLbl: "Uploading Profile Picture...")
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                if let imgData = image.pngData() {
                    uploadProfileImage(imgData, image: image)
                } else {
                    Core.HideProgress(self)
                }
            } else {
                Core.HideProgress(self)
            }
        }
    }
}

// MARK: - ProfileEditDelegate -
extension ProfileViewController: ProfileEditDelegate  {

    func didChangeProfileData(_ data: String, code: String) {
        self.setProfileData()
        switch editIndex {
        case 1:
            //Name
//            self.setProfileData()
            break
        case 2:
            //Mobile Number
//            self.setProfileData()
//            self.setProfileData("", mobile: data, email: "")
//            UserDefaults.standard.set(data, forKey: "ProfileMobile")
//            UserDefaults.standard.set(code, forKey: "CountryCode")
            break
        default:
            //Email Id
//            self.setProfileData()
            break
        }
    }
}
