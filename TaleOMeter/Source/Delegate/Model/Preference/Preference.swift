//
//  Preference.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

struct Preference {
    let Id: Int
    let Name: String
    let Preference_category_id: Int
    let Image: String
    let Created_at: String
    let Updated_at: String
    let Deleted_at: String
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
    let Id: Int
    let User_id: Int
    let Preference_bubble_id: Int
    let Created_at: String
    let Updated_at: String
    let Deleted_at: String
    let Preference_bubble: Preference
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
    var Preference_bubble_ids = String()
}
