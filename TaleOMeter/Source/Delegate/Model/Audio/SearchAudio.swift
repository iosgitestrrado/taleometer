//
//  SearchAudio.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/03/22.
//


import UIKit
import SwiftyJSON

struct SearchAudio {
    
    var Id = Int()
    var User_id = Int()
    var Text = String()
    var Created_at = String()
    var Updated_at = String()
    
    init() { }
    init(_ json: JSON) {
        Id = json["id"].intValue
        User_id = json["user_id"].intValue
        Text = json["text"].stringValue
        Created_at = json["created_at"].stringValue
        Updated_at = json["updated_at"].stringValue
    }
}

/*{
 "id": 34,
 "user_id": 67,
 "text": "Te",
 "created_at": "2022-03-22T05:37:46.000000Z",
 "updated_at": "2022-03-22T05:37:46.000000Z"
},*/

struct SearchAudioRequest: Codable {
    var text = String()
    var page = String()
    var limit = Int()
}

struct SearchDeleteRequest: Codable {
    var audio_search_id = Int()
}

