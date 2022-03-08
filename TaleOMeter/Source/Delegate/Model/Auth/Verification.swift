//
//  Verification.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

struct Verification {
    let Id: Int
    let User_code: String
    let Fname: String
    let Lname: String
    let Phone: String
    let Isd_code: Int
    let Email: String
    let Email_verified_at: String
    let Address1: String
    let Address2: String
    let Location: String
    let State: String
    let Country: String
    let Role_id: Int
    let Fb_id: String
    let Google_id: String
    let Apple_id: String
    let Avatar: String
    let Thumb: String
    let Is_active: Bool
    let Active_link: String
    let Is_login: Bool
    let Notify: Bool
    let Push_notify:Bool
    let DeviceToken: String
    let Os: String
    let Current_active: Bool
    let Created_at: String
    let Updated_at: String
    let Is_deleted: Bool
}

struct VerificationRequest: Encodable {
    var Mobile = String()
    var Otp = Int()
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
