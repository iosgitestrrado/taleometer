//
//  FavouriteAudioClient.swift
//  TaleOMeter
//
//  Created by Durgesh on 11/03/22.
//

class FavouriteAudioClient {
    static func get(_ pageNumber: Int, completion: @escaping([Favourite]?) -> Void) {
        APIClient.shared.get("page=\(pageNumber)", feed: .FavoriteAudio) { result in
            ResponseAPI.getResponseArray(result) { response in
                var favs = [Favourite]()
                if let fav = response {
                    fav.forEach({ (object) in
                        favs.append(Favourite(object))
                    })
                }
                completion(favs)
            }
        }
    }
    
    static func add(_ favRequest: FavouriteRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(favRequest, feed: .AddFavoriteAudio) { result in
            ResponseAPI.getResponseJsonBool(result) { status in
                completion(status)
            }
        }
    }
    
    static func remove(_ favRequest: FavouriteRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.deleteJson(favRequest, query: "", feed: .RemoveFavoriteAudio) { result in
            ResponseAPI.getResponseJsonBool(result) { status in
                completion(status)
            }
        }
    }
}
