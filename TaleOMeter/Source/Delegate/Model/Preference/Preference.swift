//
//  Preference.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

import SwiftyJSON
import UIKit

struct Preference {
    var Id = Int()
    var Name = String()
    var Preference_category_id = Int()
   // var Image = UIImage()
    var ImageUrl = String()
    var Created_at = String()
    var Updated_at = String()
    var Deleted_at = String()
    
    init() { }
    init(_ json: JSON) {
        Id = json["id"].intValue
        Name = json["name"].stringValue
        Preference_category_id = json["preference_category_id"].intValue
        //ImageUrl = Constants.baseURL.appending("/\(json["image"].stringValue)")
        if let urlString = json["image"].string {
            ImageUrl = Core.verifyUrl(urlString) ? urlString :   Constants.baseURL.appending("/\(urlString)")
        }
        //Core.setImage(Constants.baseURL.appending("/\(json["image"].stringValue)"), image: &Image)
        Created_at = json["created_at"].stringValue
        Updated_at = json["updated_at"].stringValue
        Deleted_at = json["deleted_at"].stringValue
    }
}
/*
 "id": 9,
 "name": "Modi",
 "preference_category_id": 7,
 "image": "storage/app/public/preference_bubble/NPmSzgFlXAs4R6RV2pRL7Fg1q83sP4jXnEJrznxu.jpg",
 "created_at": "2022-03-02T06:01:50.000000Z",
 "updated_at": "2022-03-04T11:57:20.000000Z",
 "deleted_at": null*/

struct UserPreference {
    var Id = Int()
    var User_id = Int()
    var Preference_bubble_id = Int()
    var Created_at = String()
    var Updated_at = String()
    var Deleted_at = String()
    var Preference_bubble = Preference()
    
    init() { }
    init(_ json: JSON) {
        Id = json["id"].intValue
        User_id = json["user_id"].intValue
        Preference_bubble_id = json["preference_bubble_id"].intValue
        Created_at = json["created_at"].stringValue
        Updated_at = json["updated_at"].stringValue
        Deleted_at = json["deleted_at"].stringValue
        if let preference = json["preference_bubble"].dictionaryObject {
            Preference_bubble = Preference(JSON(preference))
        }
    }
}

/*{
 "id": 24,
 "user_id": 26,
 "preference_bubble_id": 9,
 "created_at": "2022-03-08T13:26:11.000000Z",
 "updated_at": "2022-03-08T13:26:11.000000Z",
 "preference_bubble": {
     "id": 9,
     "name": "Modi",
     "preference_category_id": 7,
     "image": "storage/app/public/preference_bubble/NPmSzgFlXAs4R6RV2pRL7Fg1q83sP4jXnEJrznxu.jpg",
     "created_at": "2022-03-02T06:01:50.000000Z",
     "updated_at": "2022-03-04T11:57:20.000000Z",
     "deleted_at": null
 }
}*/

struct PreferenceRequest: Codable {
    var preference_bubble_ids = [Int]()
}
