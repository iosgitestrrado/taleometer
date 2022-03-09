//
//  AudioClient.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

import Foundation

class AudioClient {
    static func get(_ audioReq: AudioRequest, genreId: Int, completion: @escaping([Audio]?) -> Void) {
        APIClient.shared.post(audioReq, feed: .AudioStories) { result in
            ResponseAPI.getResponseArray(result) { response in
                var audios = [Audio]()
                if let audio = response {
                    audio.forEach({ (object) in
                        let aud = Audio(object)
                        if aud.Genre_id == genreId {
                            audios.append(aud)
                        }
                    })
                }
                completion(audios)
            }
        }
    }
    
    static func getGuest(_ genreId: Int, completion: @escaping([Audio]?) -> Void) {
        APIClient.shared.get("", feed: .GuestAudioStories, completion: { result in
            ResponseAPI.getResponseArray(result) { response in
                var audios = [Audio]()
                if let audio = response {
                    audio.forEach({ (object) in
                        let aud = Audio(object)
                        if aud.Genre_id == genreId {
                            audios.append(aud)
                        }
                    })
                }
                completion(audios)
            }
        })
    }
}

