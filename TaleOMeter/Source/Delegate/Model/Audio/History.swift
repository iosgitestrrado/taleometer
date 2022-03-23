//
//  History.swift
//  TaleOMeter
//
//  Created by Durgesh on 23/03/22.
//

import UIKit
import SwiftyJSON

struct History {
    
    var Id = Int()
    var User_id = Int()
    var Audio_story_id = Int()
    var Time = Int()
    var Created_at = String()
    var Updated_at = String()
    var Audio_story = Audio()
    
    init() { }
    init(_ json: JSON) {
        Id = json["id"].intValue
        User_id = json["user_id"].intValue
        Audio_story_id = json["audio_story_id"].intValue
        Created_at = json["created_at"].stringValue
        Updated_at = History.dateToSQLDate(json["updated_at"].stringValue)
        Time = json["time"].intValue
        
        if let audio_story = json["audio_story"].dictionaryObject {
            Audio_story = Audio(JSON(audio_story))
        }
    }
    
    static func dateToSQLDate(_ string: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        guard let date = dateFormatter.date(from: string) else { return "" }
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter.string(from: date)
    }
}

struct HistoryAddRequest: Codable {
    var audio_story_id = Int()
    var time = Int()
}

struct HistoryUpdateRequest: Codable {
    var audio_history_id = Int()
    var time = Int()
}

/*{
 "id": 11,
 "user_id": 67,
 "audio_story_id": 3,
 "time": 30,
 "created_at": "2022-03-11T15:16:05.000000Z",
 "updated_at": "2022-03-11T15:16:05.000000Z",
 "audio_story": {
     
 }
}*/
