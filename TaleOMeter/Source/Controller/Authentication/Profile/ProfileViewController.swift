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
    @IBOutlet weak var nameLabelView: UIView!
    @IBOutlet weak var emailLabelView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var imageOptionPopup: UIView!
    @IBOutlet weak var customActionSheet: UIView!
    
    @IBOutlet weak var notificationSwitch: UIButton!
    @IBOutlet weak var autoPlaySwitch: UIButton!
    @IBOutlet weak var autoPlayView: UIView!

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
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true, titleInLeft: true, backImage: true)
        
        if !isOnlyTrivia {
            //Add footer view and manager current view frame
            FooterManager.addFooter(self, isProfile: true)
            if AudioPlayManager.shared.isMiniPlayerActive {
                AudioPlayManager.shared.addMiniPlayer(self)
            }
        }
        getProfileData()
        notificationSwitch.isSelected = true
        autoPlaySwitch.isSelected = UserDefaults.standard.bool(forKey: "AutoplayEnable")
        autoPlayView.isHidden = isOnlyTrivia
        
        Core.ShowProgress(self, detailLbl: "Getting Profile details...")
        setProfileData()
        self.profileImage.image = Login.defaultProfileImage
        if let imgData = profileData?.ImageData, let img = UIImage(data: imgData) {
            self.profileImage.image = img
        }
        Core.HideProgress(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        if isMovingFromParent {
//            self.sideMenuController!.toggleRightView(animated: false)
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func changeNotification(_ sender: UIButton) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        sender.isSelected = !sender.isSelected
        Core.ShowProgress(self, detailLbl: "")
        OtherClient.setNotificationSetting(NotificationSetRequest(value: sender.isSelected ? 1 : 0)) { status in
            Core.HideProgress(self)
        }
    }
    
    @IBAction func changeAutoplay(_ sender: UIButton) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        sender.isSelected = !sender.isSelected
        Core.ShowProgress(self, detailLbl: "")
        OtherClient.setAutoPlaySetting(AutoplaySetRequest(value: sender.isSelected ? "Enable" : "Disable")) { status in
            if let st = status, st {
                UserDefaults.standard.set(sender.isSelected, forKey: "AutoplayEnable")
                UserDefaults.standard.synchronize()
            }
            Core.HideProgress(self)
        }
    }
    
    private func setProfileData() {
        
        if let pfData = Login.getProfileData() {
            profileData = pfData
            notificationSwitch.isSelected = pfData.Push_notify
            autoPlaySwitch.isSelected = pfData.Autoplay.lowercased().contains("enable")
        }
        
        self.pointsLabel.text = "\(profileData?.Points ?? 0)"
        
        let name = profileData?.User_code ?? ""
        let displayName = profileData?.Fname ?? ""
        let mobile = "+\(profileData?.Isd_code ?? 0) \(profileData?.Phone ?? "")"
        let email = profileData?.Email ?? ""
        
        let pencilAtt = Core.getImageString("pencil")
        let phoneAtt = Core.getImageString("phone")
        let emailAtt = Core.getImageString("email")

        let nameAttText = NSMutableAttributedString(string: "\(name)  ")
        let titleAttText = NSMutableAttributedString(string: "\(displayName)  ")
        let mobileText = NSMutableAttributedString(string: " \(mobile)  ")
        let emailText = NSMutableAttributedString(string: " \(email)  ")
        
        if !displayName.isBlank {
            titleAttText.append(pencilAtt)
            self.titleLabel.attributedText = titleAttText
        }
        
//        self.nameLabelView.isHidden = name.isBlank
        //if !name.isBlank {
            nameAttText.append(pencilAtt)
            self.nameLabel.attributedText = nameAttText
        //}
        
        if !mobile.isBlank {
            let mobileAttText = phoneAtt
            mobileAttText.append(mobileText)
            mobileAttText.append(pencilAtt)
            self.mobileLabel.attributedText = mobileAttText
        }
        
       // if !email.isBlank {
            let emailAttText = emailAtt
            emailAttText.append(emailText)
            emailAttText.append(pencilAtt)
            self.emailLabel.attributedText = emailAttText
       // }
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
            //Display Name
            guard let myobject = UIStoryboard(name: Constants.Storyboard.auth, bundle: nil).instantiateViewController(withIdentifier: "ProfileEditViewController") as? ProfileEditViewController else { break }
            myobject.titleString = "Change Display Name"
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
        case 4:
            //Name
            guard let myobject = UIStoryboard(name: Constants.Storyboard.auth, bundle: nil).instantiateViewController(withIdentifier: "ProfileEditViewController") as? ProfileEditViewController else { break }
            myobject.titleString = "Change Name"
            myobject.fieldValue = profileData?.User_code ?? ""
            myobject.profileDelegate = self
            self.navigationController?.pushViewController(myobject, animated: true)
            break
        default:
            //Image
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.showHideView(self.customActionSheet, isHidden: false)

            /*let alert = UIAlertController(title: "Please Select", message: "", preferredStyle: .actionSheet)
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
                self.removeProfileImage()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }*/
            break
        }
    }
    
    // MARK: Change profile image options // Camera - 1, Photo - 2, Cancel - 3, 4 - Update Profile, 5 - Delete Profile, 6 - Close Option
    @IBAction func tapOnImageOptions(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            // Open Camera
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
            break
        case 2:
            // Open Gallary
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
            break
        case 0, 4:
            // 0 - Cancel // 4 - Update Profile
            self.showHideView(self.imageOptionPopup, isHidden: sender.tag == 0)
            break
        case 5:
            // Remove Profile
            self.showHideView(self.customActionSheet, isHidden: true)
            self.removeProfileImage()
            break
        default:
            // Close Option
            self.showHideView(self.customActionSheet, isHidden: true)
            break
        }
    }
    
    private func showHideView(_ viewd: UIView, isHidden: Bool) {
        UIView.transition(with: viewd, duration: 0.5, options: .transitionCrossDissolve, animations: {
            UIView.animate(withDuration: 0.25, animations: {
                viewd.isHidden = isHidden
            })
        }, completion: nil)
    }
}

// MARK: Call API's
extension ProfileViewController {
    
    private func getProfileData() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        AuthClient.getProfile { result in
            if let response = result {
                self.profileData = response
                Login.storeProfileData(response)
                
                self.setProfileData()
                self.profileImage.image = Login.defaultProfileImage
                if let imgData = self.profileData?.ImageData, let img = UIImage(data: imgData) {
                    self.profileImage.image = img
                }
            }
            Core.HideProgress(self)
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
//                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateUserData"), object: nil)
                PromptVManager.present(self, verifyMessage: "Your profile image is successfully changed", isUserStory: true)
            }
            Core.HideProgress(self)
        }
    }
    
    private func removeProfileImage() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self, methodName: "removeProfileImage")
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        AuthClient.removeProfileImage { result in
            if let response = result {
                self.profileData = response
                Login.storeProfileData(response)
                self.profileImage.image = Login.defaultProfileImage
//                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateUserData"), object: nil)
                PromptVManager.present(self, verifyMessage: "Your profile image is successfully changed", isUserStory: true)
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
            
            if let imageOrig = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                let image = imageOrig.makeFixOrientation()
                self.showHideView(self.customActionSheet, isHidden: true)
                self.showHideView(self.imageOptionPopup, isHidden: true)

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
    
    private func imageOrientation(_ src:UIImage)->UIImage {
        if src.imageOrientation == UIImage.Orientation.up {
            return src
        }
        var transform: CGAffineTransform = CGAffineTransform.identity
        switch src.imageOrientation {
        case UIImage.Orientation.down, UIImage.Orientation.downMirrored:
            transform = transform.translatedBy(x: src.size.width, y: src.size.height)
            transform = transform.rotated(by: CGFloat(Float.pi))
            break
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored:
            transform = transform.translatedBy(x: src.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Float.pi))
            break
        case UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: src.size.height)
            transform = transform.rotated(by: CGFloat(-Float.pi))
            break
        case UIImage.Orientation.up, UIImage.Orientation.upMirrored:
            break
        default:
            break;
        }

        switch src.imageOrientation {
        case UIImage.Orientation.upMirrored, UIImage.Orientation.downMirrored:
            transform.translatedBy(x: src.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImage.Orientation.leftMirrored, UIImage.Orientation.rightMirrored:
            transform.translatedBy(x: src.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImage.Orientation.up, UIImage.Orientation.down, UIImage.Orientation.left, UIImage.Orientation.right:
            break
        default:
            break
        }

        let ctx:CGContext = CGContext(data: nil, width: Int(src.size.width), height: Int(src.size.height), bitsPerComponent: (src.cgImage)!.bitsPerComponent, bytesPerRow: 0, space: (src.cgImage)!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

        ctx.concatenate(transform)

        switch src.imageOrientation {
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored, UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.height, height: src.size.width))
            break
        default:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.width, height: src.size.height))
            break
        }

        let cgimg:CGImage = ctx.makeImage()!
        let img:UIImage = UIImage(cgImage: cgimg)

        return img
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

// MARK: - NoInternetDelegate -
extension ProfileViewController: NoInternetDelegate {
    func connectedToNetwork(_ methodName: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.perform(Selector((methodName)))
        }
    }
}
