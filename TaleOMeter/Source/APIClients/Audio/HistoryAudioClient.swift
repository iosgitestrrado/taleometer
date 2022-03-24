//
//  HistoryAudioClient.swift
//  TaleOMeter
//
//  Created by Durgesh on 23/03/22.
//

class HistoryAudioClient {
    static func get(_ page: String, limit: Int, completion: @escaping([History]?) -> Void) {
        APIClient.shared.get("?page=\(page)&limit=\(limit)", feed: .GetAudioHistory) { result in
            ResponseAPI.getResponseArray(result) { response in
                var histories = [History]()
                if let hiss = response {
                    hiss.forEach { object in
                        histories.append(History(object))
                    }
                }
                completion(histories)
            }
        }
    }
    
    static func add(_ req: HistoryAddRequest, completion: @escaping(History?) -> Void) {
        APIClient.shared.postJson(parameters: req, feed: .AddAudioHistory) { result in
            ResponseAPI.getResponseJson(result) { response in
                var audioHistory = History()
                if let data = response {
                    audioHistory = History(data)
                }
                completion(audioHistory)
            }
        }
    }
    
    static func update(_ req: HistoryUpdateRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(parameters: req, feed: .UpdateAudioHistory) { result in
            ResponseAPI.getResponseJsonBool(result) { status in
                completion(status)
            }
        }
    }
}
