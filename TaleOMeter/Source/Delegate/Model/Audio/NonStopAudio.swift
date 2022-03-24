//
//  NonStopAudio.swift
//  TaleOMeter
//
//  Created by Durgesh on 24/03/22.
//

import UIKit
import SwiftyJSON
import AVFoundation
import AVKit

struct NonStopAudio {
    var Id = Int()
    var Audio_story_id = Int()
    var Link_audio_id: Int?
    var TypeType = String()
    var Created_at = String()
    var Updated_at = String()
    var Deleted_at = String()
    var Audio_story = Audio()
    var Link_audio = LinkAudio()
    
    init() { }
    init(_ json: JSON) {
        
        Id = json["id"].intValue
        Audio_story_id = json["audio_story_id"].intValue
        Link_audio_id = json["link_audio_id"].int
        TypeType = json["type"].stringValue
        Created_at = json["created_at"].stringValue
        Updated_at = json["updated_at"].stringValue
        Deleted_at = json["deleted_at"].stringValue
        
        if let audio_story = json["audio_story"].dictionaryObject {
            Audio_story = Audio(JSON(audio_story))
        }
        if let link_audio = json["link_audio"].dictionaryObject {
            Link_audio = LinkAudio(JSON(link_audio))
        }
    }
}


/*
 "id": 1,
 "audio_story_id": 14,
 "link_audio_id": null,
 "type": "Audio Story",
 "created_at": "2022-03-07T10:41:35.000000Z",
 "updated_at": "2022-03-16T12:30:58.000000Z",
 "deleted_at": null,
 "audio_story": {},
 "link_audio": null*/

struct LinkAudio {
    
    var Id = Int()
    var Title = String()
    var File = String()
    var Added_to_nonstop = Bool()
    var Created_at = String()
    var Updated_at = String()
    var Deleted_at = String()
    
    init() { }
    init(_ json: JSON) {
        Id = json["id"].intValue
        Title = json["title"].stringValue
        File = Constants.baseURL.appending("/\(json["file"].stringValue)")
        Added_to_nonstop = json["added_to_nonstop"].boolValue
        Created_at = json["created_at"].stringValue
        Updated_at = json["updated_at"].stringValue
        Deleted_at = json["deleted_at"].stringValue
    }
    
}

/*{
 "id": 9,
 "title": "SoundHelix Song 1",
 "file": "storage/app/public/link_audio/E8dasQ5OBXxAmeOHoYGAdXigK8Xq6DFiFQHaNT7d.mp3",
 "added_to_nonstop": 1,
 "created_at": "2022-03-08T08:39:42.000000Z",
 "updated_at": "2022-03-10T06:15:25.000000Z",
 "deleted_at": null
}*/

