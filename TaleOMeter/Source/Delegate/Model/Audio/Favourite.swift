//
//  Favourite.swift
//  TaleOMeter
//
//  Created by Durgesh on 11/03/22.
//

import UIKit
import SwiftyJSON

struct Favourite {
    
    var Id = Int()
    var User_id = Int()
    var Audio_story_id = Int()
    var Created_at = String()
    var Ypdated_at = String()
    var Audio_story = Audio()
    
    init() { }
    init(_ json: JSON) {
        Id = json["id"].intValue
        User_id = json["user_id"].intValue
        Audio_story_id = json["audio_story_id"].intValue
        Created_at = json["created_at"].stringValue
        Ypdated_at = json["updated_at"].stringValue
        
        if let audio_story = json["audio_story"].dictionaryObject {
            Audio_story = Audio(JSON(audio_story))
        }
    }
}

/*{
 "id": 3,
 "user_id": 26,
 "audio_story_id": 3,
 "created_at": "2022-03-04T10:09:37.000000Z",
 "updated_at": "2022-03-04T10:09:37.000000Z",
 "audio_story": {
     "id": 3,
     "title": "Shikamani",
     "image": "storage/app/public/audio_story/image/dT50xWtGTMf7n2YB3LycAOsd7zXc5bJ6XVkOrGAT.png",
     "file": "storage/app/public/audio_story/audio/g1HmRuFdWu8jQNQc7JyK11uYV7fcT9S8nd2KpnDP.mp3",
     "genre_id": 15,
     "story_id": 5,
     "plot_id": 7,
     "narration_id": 5,
     "is_nonstop": 0,
     "is_active": 1,
     "created_at": "2022-03-02T11:26:29.000000Z",
     "updated_at": "2022-03-10T06:33:11.000000Z",
     "deleted_at": null,
     "views_count": 5
 }
}*/

struct FavouriteRequest: Codable {
    var audio_story_id = Int()
}
