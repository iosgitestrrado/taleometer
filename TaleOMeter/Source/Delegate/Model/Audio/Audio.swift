//
//  Audio.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

struct Audio {
    let Id: String
    let Title: String
    let Image: String
    let File: String
    let Genre_id: String
    let Story_id: String
    let Plot_id: String
    let Narration_id: String
    let Is_nonstop: String
    let Is_active: String
    let Created_at: String
    let Updated_at: String
    let Deleted_at: String
    let Views_count: String
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
    var Page = Int()
    var Limit = Int()
}

struct AudioAddRequst: Codable {
    var Audio_story_id = Int()
    var Time = Int()
}

struct SearchAudioRequest: Codable {
    var Text = String()
    var Page = Int()
}

struct SearchDeleteRequest: Codable {
    var Audio_search_id = Int()
}

struct FavoriteRequest: Codable {
    var Audio_story_id = Int()
}
