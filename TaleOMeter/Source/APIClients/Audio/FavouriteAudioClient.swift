//
//  FavouriteAudioClient.swift
//  TaleOMeter
//
//  Created by Durgesh on 11/03/22.
//

class FavouriteAudioClient {
    static func get(_ pageNumber: String, completion: @escaping([Audio]?) -> Void) {
        APIClient.shared.get("?page=\(pageNumber)", feed: .FavoriteAudio) { result in
            ResponseAPI.getResponseArray(result) { response in
                var favs = [Audio]()
                if let fav = response {
                    fav.forEach({ (object) in
                        let favor = Favourite(object)
                        favs.append(favor.Audio_story)
                    })
                }
                completion(favs)
            }
        }
    }
    
    static func add(_ favRequest: FavouriteRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(favRequest, feed: .AddFavoriteAudio) { result in
            ResponseAPI.getResponseJsonBool(result, showSuccMessage: true) { status in
                self.get("all") { response in
                    if let data = response, data.count > 0 {
                        favouriteAudio = data
                    }
                    completion(status)
                }
            }
        }
    }
    
    static func remove(_ favRequest: FavouriteRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.deleteJson(favRequest, query: "", feed: .RemoveFavoriteAudio) { result in
            ResponseAPI.getResponseJsonBool(result, showSuccMessage: true) { status in
                self.get("all") { response in
                    if let data = response, data.count > 0 {
                        favouriteAudio = data
                    }
                    completion(status)
                }
            }
        }
    }
}
