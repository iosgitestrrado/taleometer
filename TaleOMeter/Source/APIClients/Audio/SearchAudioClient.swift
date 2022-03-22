//
//  SearchAudioClient.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/03/22.
//

class SearchAudioClient {
    static func get(_ req: SearchAudioRequest, completion: @escaping([Audio]?) -> Void) {
        APIClient.shared.post(parameters: req, feed: .SearchAudio) { result in
            ResponseAPI.getResponseArray(result, showAlert: false) { response in
                var searches = [Audio]()
                if let seas = response {
                    seas.forEach({ (object) in
                        searches.append(Audio(object))
                    })
                }
                completion(searches)
            }
        }
    }
    
    static func getRecent(_ pageNumber: String, limit: Int, completion: @escaping([SearchAudio]?) -> Void) {
        APIClient.shared.get("?page=\(pageNumber)&limit=\(limit)", feed: .RecentSearchAudio) { result in
            ResponseAPI.getResponseArray(result, showAlert: false) { response in
                var searches = [SearchAudio]()
                if let seas = response {
                    seas.forEach({ (object) in
                        searches.append(SearchAudio(object))
                    })
                }
                completion(searches)
            }
        }
    }
    
    static func delete(_ req: SearchDeleteRequest, removeAll: Bool = false, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.deleteJson(req, query: "", feed: removeAll ? .RemoveAllSearchAudio : .RemoveSearchAudio) { result in
            ResponseAPI.getResponseJsonBool(result, showSuccMessage: true) { status in
                completion(status)
            }
        }
    }
//    static func deleteAll(_ completion: @escaping(Bool?) -> Void) {
//        APIClient.shared.deleteJson(EmptyRequest(), query: "", feed: .RemoveAllSearchAudio) { result in
//            ResponseAPI.getResponseJsonBool(result, showSuccMessage: true) { status in
//                completion(status)
//            }
//        }
//    }
}
