//
//  Login.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

import Foundation
import UIKit
import SwiftyJSON

struct Login {
    
    static let defaultProfileImage = UIImage(named: "profile_default")!
    
    public static func setGusetData() {
        if self.getProfileData() == nil {
            var profileData = ProfileData()
            
            if let data = defaultProfileImage.pngData() {
                profileData.ImageData = data
            }
            profileData.Phone = "00000 00000"
            profileData.Isd_code = 0
            profileData.Country_code = "IN"
            profileData.Email = "temp@temp.temp"
            profileData.Fname = "Guest"
            self.storeProfileData(profileData)
        }
    }
    
    public static func removeStoryBoardData() {
        if var profileData = self.getProfileData(), !profileData.StoryBoardId.isBlank {
            profileData.StoryBoardId = ""
            profileData.StoryBoardName = ""
            self.storeProfileData(profileData)
        }
    }
    
    public static func storeProfileData(_ profileData: ProfileData) {
        do {
            UserDefaults.standard.set(profileData.Autoplay.lowercased().contains("enable"), forKey: "AutoplayEnable")
            UserDefaults.standard.synchronize()
            
            // Create JSON Encoder
            let encoder = JSONEncoder()
            // Encode Note
            let data = try encoder.encode(profileData)

            // Write/Set Data
            UserDefaults.standard.set(data, forKey: Constants.UserDefault.ProfileData)
            UserDefaults.standard.synchronize()
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateUserData"), object: nil)
        } catch {
            UserDefaults.standard.synchronize()
            print("Unable to Encode (\(error))")
        }
    }
    
    public static func getProfileData() -> ProfileData? {
        if let data = UserDefaults.standard.data(forKey: Constants.UserDefault.ProfileData) {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode Note
                let verification = try decoder.decode(ProfileData.self, from: data)
                return verification
            } catch {
                print("Unable to Decode (\(error))")
                return nil
            }
        }
        return nil
    }
}

struct FBLoginModel {
    var Id = String()
    var FirstName = String()
    var Name = String()
    var LastName = String()
    var Email = String()
    var ProfilePicture = String()
    
    init(_ json: JSON) {
        Id = json["id"].stringValue
        FirstName = json["first_name"].stringValue
        Name = json["name"].stringValue
        LastName = json["last_name"].stringValue
        Email = json["email"].stringValue
        if let picture = json["picture"].dictionaryObject {
            let picD = JSON(picture)
            if let pictureData = picD["data"].dictionaryObject {
                let pictureD = JSON(pictureData)
                if let pictureDataURL = pictureD["url"].string {
                    ProfilePicture = pictureDataURL
                }
            }
        }
    }
}

struct LoginRequest: Encodable {
    var mobile = String()
    var isd_code = String()
    var country_code = String()
}

struct SocialLoginRequest: Encodable {
    var social_media = String()
    var login_id = String()
    var fname = String()
    var email = String()
    var phone = String()
    var country_code = String()
    var avatar = String()

    var model = Core.GetDeviceModel()
    var osversion = Core.GetDeviceOSVersion()
    var appversion = Core.GetAppVersion()
    var os = Core.GetDeviceOS()
    var manufacturer = "Apple"
    var device_name = "ios"
}

struct NotificationRequest: Encodable {
    var token = String()
}
