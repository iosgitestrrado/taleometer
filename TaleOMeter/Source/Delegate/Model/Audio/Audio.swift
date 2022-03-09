//
//  Audio.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

import UIKit
import SwiftyJSON

struct Audio {
    var Id = Int()
    var Title = String()
    var Image = UIImage()
    var File = String()
    var Genre_id = Int()
    var Story_id = Int()
    var Plot_id = Int()
    var Narration_id = Int()
    var Is_nonstop = Bool()
    var Is_active = Bool()
    var Created_at = String()
    var Updated_at = String()
    var Deleted_at = String()
    var Views_count = Int()
    
    init() { }
    init(_ json: JSON) {
        Id = json["id"].intValue
        Title = json["name"].stringValue
        let imageURL = Constants.baseURL.appending("/\(json["image"].stringValue)")
        Image = UIImage(named: "logo")!
        if let url = URL(string: imageURL) {
            do {
                let data = try Data(contentsOf: url)
                Image = UIImage(data: data) ?? UIImage(named: "logo")!
            } catch { }
        }
        File = Constants.baseURL.appending("/\(json["File"].stringValue)")
        Genre_id = json["genre_id"].intValue
        Story_id = json["story_id"].intValue
        Plot_id = json["plot_id"].intValue
        Narration_id = json["narration_id"].intValue
        Is_nonstop = json["is_nonstop"].boolValue
        Is_active = json["is_active"].boolValue
        Created_at = json["created_at"].stringValue
        Updated_at = json["updated_at"].stringValue
        Deleted_at = json["deleted_at"].stringValue
        Views_count = json["views_count"].intValue
    }
}

/*
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
 "updated_at": "2022-03-04T07:16:07.000000Z",
 "deleted_at": null,
 "views_count": 3
}*/


struct AudioRequest: Codable {
    var page = Int()
    var limit = Int()
}

struct AudioAddRequst: Codable {
    var audio_story_id = Int()
    var time = Int()
}

struct SearchAudioRequest: Codable {
    var text = String()
    var page = Int()
}

struct SearchDeleteRequest: Codable {
    var audio_search_id = Int()
}

struct FavoriteRequest: Codable {
    var audio_story_id = Int()
}
