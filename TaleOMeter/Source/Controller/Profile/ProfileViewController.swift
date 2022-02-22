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
        setProfileData("Durgesh Timbadiya", mobile: "+91 9624542749", email: "durgesh.timbadiya@hotmail.com")
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
            myobject.profileDelegate = self
            self.navigationController?.pushViewController(myobject, animated: true)
            break
        case 2:
            //Mobile Number
            guard let myobject = UIStoryboard(name: Storyboard.auth, bundle: nil).instantiateViewController(withIdentifier: "ChangeMobileNumberVC") as? ChangeMobileNumberVC else { break }
            myobject.profileDelegate = self
            self.navigationController?.pushViewController(myobject, animated: true)
            break
        case 3:
            //Email Id
            guard let myobject = UIStoryboard(name: Storyboard.auth, bundle: nil).instantiateViewController(withIdentifier: "ProfileEditViewController") as? ProfileEditViewController else { break }
            myobject.titleString = "Change Email ID"
            myobject.profileDelegate = self
            self.navigationController?.pushViewController(myobject, animated: true)
            break
        default:
            //Image
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.navigationController?.present(imagePicker, animated: true, completion: nil)
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
        self.imagePicker.dismiss(animated: true) {
            PromptVManager.present(self, isAudioView: false, verifyMessage: "Your Profile Image is Successfully Changed")
        }
    }
}

// MARK: - ProfileEditDelegate -
extension ProfileViewController: ProfileEditDelegate  {

    func didChangeProfileData(_ data: String) {
        switch editIndex {
        case 1:
            //Name
            self.setProfileData(data, mobile: "", email: "")
            break
        case 2:
            //Mobile Number
            self.setProfileData("", mobile: data, email: "")
            break
        default:
            //Email Id
            self.setProfileData("", mobile: "", email: data)
            break
        }
    }
}
