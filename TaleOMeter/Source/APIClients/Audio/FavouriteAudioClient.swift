//
//  FavouriteAudioClient.swift
//  TaleOMeter
//
//  Created by Durgesh on 11/03/22.
//

class FavouriteAudioClient {
    static func get(_ pageNumber: String, completion: @escaping([Audio]?) -> Void) {
        APIClient.shared.get(pageNumber == "all" ? "?page=\(pageNumber)" : "?page=\(pageNumber)&limit=10", feed: .FavoriteAudio) { result in
            ResponseAPI.getResponseArray(result, showAlert: false) { response in
                var favs = [Audio]()
                if let fav = response {
                    fav.forEach({ (object) in
                        let favor = Favourite(object)
                        favs.append(favor.Audio_story)
                    })
                }
                if pageNumber == "all" {
                    favouriteAudio = favs
                }
                completion(favs)
            }
        }
    }
    
    static func add(_ favRequest: FavouriteRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(parameters: favRequest, feed: .AddFavoriteAudio) { result in
            ResponseAPI.getResponseJsonBool(result, showSuccMessage: true) { status in
                self.get("all") { response in
                    completion(status)
                }
            }
        }
    }
    
    static func remove(_ favRequest: FavouriteRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.deleteJson(favRequest, query: "", feed: .RemoveFavoriteAudio) { result in
            ResponseAPI.getResponseJsonBool(result, showSuccMessage: true) { status in
                self.get("all") { response in
                    completion(status)
                }
            }
        }
    }
}
