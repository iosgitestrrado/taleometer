//
//  ProfileData.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

import SwiftyJSON

struct ProfileData: Codable {
    var Id = Int()
    var User_code = String()
    var Fname = String()
    var Lname = String()
    var Phone = String()
    var Isd_code = Int()
    var Country_code = String()
    var Email = String()
    var Email_verified_at = String()
//    var Address1 = String()
//    var Address2 = String()
//    var Location = String()
//    var State = String()
//    var Country = String()
//    var Role_id = Int()
//    var Fb_id = String()
//    var Google_id = String()
//    var Apple_id = String()
    var Avatar = String()
    var Thumb = String()
    var Is_active = Bool()
    var Active_link = String()
    var Is_login = Bool()
    var Notify = Bool()
    var DeviceToken = String()
    var Os = String()
    var Current_active = Bool()
    var Created_at = String()
    var Updated_at = String()
    var Is_deleted = Bool()
    var Autoplay = String()
    var Push_notify = Bool()
    
    var StoryBoardName = String()
    var StoryBoardId = String()
    var ImageData = Data()
    var Has_preference = false
    
    init() { }
    init(_ json: JSON) {
        Id = json["id"].intValue
        User_code = json["user_code"].stringValue
        Fname = json["fname"].stringValue
        Lname = json["lname"].stringValue
        Phone = json["phone"].stringValue
        Isd_code = json["isd_code"].intValue
        Country_code = json["country_code"].stringValue
        Email = json["email"].stringValue
        Email_verified_at = json["email_verified_at"].stringValue
//        Address1 = json["address1"].stringValue
//        Address2 = json["address2"].stringValue
//        Location = json["location"].stringValue
//        State = json["state"].stringValue
//        Country = json["country"].stringValue
//        Role_id = json["role_id"].intValue
//        Fb_id = json["fb_id"].stringValue
//        Google_id = json["google_id"].stringValue
//        Apple_id = json["apple_id"].stringValue
       // Avatar = Constants.baseURL.appending("/\(json["avatar"].stringValue)")
        if let urlString = json["avatar"].string {
            Avatar = Core.verifyUrl(urlString) ? urlString :   Constants.baseURL.appending("/\(urlString)")
        }
        if let url = URL(string: Avatar) {
            do {
                let data = try Data(contentsOf: url)
                self.ImageData = data
            } catch {
                if let iData = Login.defaultProfileImage.pngData() {
                    self.ImageData = iData
                }
            }
        }
        Thumb = json["thumb"].stringValue
        Is_active = json["is_active"].boolValue
        Active_link = json["active_link"].stringValue
        Is_login = json["is_login"].boolValue
        Notify = json["notify"].boolValue
        DeviceToken = json["deviceToken"].stringValue
        Os = json["os"].stringValue
        Current_active = json["current_active"].boolValue
        Created_at = json["created_at"].stringValue
        Updated_at = json["updated_at"].stringValue
        Is_deleted = json["is_deleted"].boolValue
        Autoplay = json["autoplay"].stringValue
        Push_notify = json["push_notify"].boolValue
        Has_preference = json["has_preference"].boolValue
    }
}

struct VerificationRequest: Encodable {
    var mobile = String()
    var otp = Int()
    var isd_code = String()
    var country_code = String()
    var model = Core.GetDeviceModel()
    var osversion = Core.GetDeviceOSVersion()
    var appversion = Core.GetAppVersion()
    var os = Core.GetDeviceOS()
    var uuid = Core.GetDeviceId()
    var manufacturer = "Apple"
    var device_name = "ios"
}

struct VerificationUpdateRequest: Encodable {
    var mobile = String()
    var otp = Int()
    var isd_code = String()
    var country_code = String()
}
/*{
 "id": 26,
 "user_code": "Test User2",
 "fname": "Test User2",
 "lname": null,
 "phone": 9876543215,
 "isd_code": 91,
 "email": "test2@estrradoweb.com",
 "email_verified_at": null,
 "address1": null,
 "address2": null,
 "location": null,
 "state": null,
 "country": null,
 "role_id": 2,
 "fb_id": null,
 "google_id": null,
 "apple_id": null,
 "avatar": null,
 "thumb": null,
 "is_active": 1,
 "active_link": null,
 "is_login": 1,
 "notify": 0,
 "push_notify": 0,
 "deviceToken": null,
 "os": null,
 "current_active": 1,
 "created_at": "2022-03-03T11:32:52.000000Z",
 "updated_at": "2022-03-08T13:19:09.000000Z",
 "is_deleted": 0
}*/
