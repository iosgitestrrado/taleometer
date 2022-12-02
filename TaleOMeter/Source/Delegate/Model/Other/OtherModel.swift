//
//  OtherModel.swift
//  TaleOMeter
//
//  Created by Durgesh on 24/03/22.
//

import SwiftyJSON

struct NotificationModel {
    var Id = Int()
    var Title = String()
    var Content = String()
    //var Banner = UIImage()
    var BannerUrl = String()
    var Audio_story_id = -1
    var Is_active = Bool()
    var TypeType = String()
    var Created_at = String()
    var Updated_at = String()
    var Deleted_at = String()
    var Audio_story = Audio()
    var Post_id = -1
    
    init() { }
    init(_ json: JSON) {
        Id = json["id"].intValue
        Title = json["title"].stringValue
        Content = json["content"].stringValue
        if let postid =  json["post_id"].int {
            Post_id = postid
        }
//        BannerUrl = Constants.baseURL.appending("/\(json["banner"].stringValue)")
        if let urlString = json["banner"].string {
            BannerUrl = Core.verifyUrl(urlString) ? urlString :   Constants.baseURL.appending("/\(urlString)")
        }
        //Core.setImage(Constants.baseURL.appending("/\(json["banner"].stringValue)"), image: &Banner)
        if let audioId =  json["audio_story_id"].int {
            Audio_story_id = audioId
        }
        Is_active = json["is_active"].boolValue
        TypeType = json["type"].stringValue
        Created_at = Core.convertDateFormate(json["created_at"].stringValue)
        Updated_at = json["updated_at"].stringValue
        Deleted_at = json["deleted_at"].stringValue
        
        if let audio_story = json["audio_story"].dictionaryObject {
            Audio_story = Audio(JSON(audio_story))
        }
    }
}

/*{
 "id": 8,
 "title": "test2",
 "content": "This is test Content<br>",
 "banner": null,
 "audio_story_id": null,
 "is_active": 1,
 "type": "Sent",
 "created_at": "2022-03-21T16:50:14.000000Z",
 "updated_at": "2022-03-24T05:47:04.000000Z",
 "deleted_at": null,
 "audio_story": null
}*/

struct StaticContent {
    var Id = Int()
    var Title = String()
    var Slug = String()
    var Value = String()
    var Created_at = String()
    var Updated_at = String()
    
    init() { }
    init(_ json: JSON) {
        Id = json["id"].intValue
        Title = json["title"].stringValue
        Slug = json["slug"].stringValue
        Value = json["value"].stringValue
        Created_at = json["created_at"].stringValue
        Updated_at = json["updated_at"].stringValue
    }
}

/*{
 "id": 2,
 "title": "Terms And Conditions",
 "slug": "terms-and-conditions",
 "value": "<u><i>This is Terms And Conditions Content.</i></u>",
 "created_at": "2022-03-23T11:14:48.000000Z",
 "updated_at": "2022-03-23T11:18:02.000000Z"
}*/

struct UsageModel {
    var Id = Int()
    var User_id = Int()
    var Start_time = String()
    
    init() { }
    init(_ json: JSON) {
        User_id = json["user_id"].intValue
        Start_time = json["start_time"].stringValue
        Id = json["id"].intValue
    }
}
/*
 "data": {
 "user_id": 67,
 "start_time": "2022-03-23 15:54:00",
 "id": 5
}*/

struct FeedbackRequest: Encodable {
    var content = String()
}

struct NotificationSetRequest: Encodable {
    var value = Int()
}

struct AutoplaySetRequest: Encodable {
    var value = String()
}

struct StartUsageRequest: Encodable {
    var time = String()
}

struct EndUsageRequest: Encodable {
    var usage_id = Int()
    var time = String()
}
