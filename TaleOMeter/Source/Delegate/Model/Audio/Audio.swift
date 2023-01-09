//
//  Audio.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

import UIKit
import SwiftyJSON
import AVFoundation
import AVKit

struct Audio {
    var Id = Int()
    var Title = String()
    //var Image = UIImage()
    var ImageUrl = String()
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
    var Is_favorite = Bool()
    var Duration = Int()
    var Favorites_count = Int()
    var IsLinkedAudio = Bool()
    
    var Audio_story_count = Int()
    var Story = StoryModel()
    var Plot = StoryModel()
    var Narration = StoryModel()
    var TypeT = String()

//    var Stories: [Story]?
//    var Plots: [Story]?
//    var Narrations: [Story]?

    init() { }
    init(_ json: JSON) {
        Id = json["id"].intValue
        Title = json["title"].stringValue
        //Core.setImage(Constants.baseURL.appending("/\(json["image"].stringValue)"), image: &Image)
        
        if let urlString = json["image"].string {
            ImageUrl = Core.verifyUrl(urlString) ? urlString : Constants.baseURL.appending("/\(urlString)")
        }
        
        if let urlString1 = json["file"].string {
            File = Core.verifyUrl(urlString1) ? urlString1 : Constants.baseURL.appending("/\(urlString1)")
        }
        
//        ImageUrl = Constants.baseURL.appending("/\(json["image"].stringValue)")
//        File = Constants.baseURL.appending("/\(json["file"].stringValue)")
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
        Is_favorite = json["is_favorite"].boolValue
        Duration = json["duration"].intValue
        Favorites_count = json["favorites_count"].intValue
        if let audio_story = json["story"].dictionaryObject {
            Story = StoryModel(JSON(audio_story))
        }
        
        if let audio_plot = json["plot"].dictionaryObject {
            Plot = StoryModel(JSON(audio_plot))
        }
        
        if let audio_narration = json["narration"].dictionaryObject {
            Narration = StoryModel(JSON(audio_narration))
        }
        
        TypeT = json["type"].stringValue
        Audio_story_count = json["audio_story_count"].intValue
                
//        if let story = strories.first(where: { $0.Id == Story_id }) {
//            Story = story
//        }
//        if let plot = plots.first(where: { $0.Id == Plot_id }) {
//            Plot = plot
//        }
//        if let narration = narrations.first(where: { $0.Id == Narration_id }) {
//            Narration = narration
//        }
//        Stories = strories
//        Plots = plots
//        Narrations = narrations
    }
    
    static func getAudioDuration(_ file: String) -> Float {
        if let audioUrl = URL(string: file) {
            let audioAsset = AVURLAsset(url: audioUrl)
            return Float(CMTimeGetSeconds(audioAsset.duration))
        }
        return 0
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
    var page = String()
    var limit = Int()
}

struct AudioGenreRequest: Codable {
    var genre_id = Int()
    var shuffle = Int()
    var page = String()
    var limit = Int()
}

struct EndAudioRequest: Codable {
    var audio_history_id = Int()
}

struct AddAudioActionRequest: Codable {
    var audio_history_id = Int()
    var action = String()
    var time = Int()
}

public enum AudioAction: Equatable {
    case pause
    case resume

    var description: String {
        switch self {
        case .pause:
            return "pause"
        case .resume:
            return "resume"
        }
    }
}
