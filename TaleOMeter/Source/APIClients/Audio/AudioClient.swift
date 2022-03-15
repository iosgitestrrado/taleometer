//
//  AudioClient.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

import Foundation

class AudioClient {
    static func get(_ audioReq: AudioRequest, genreId: Int = -1, isNonStop: Bool = false, completion: @escaping([Audio]?) -> Void) {
        if UserDefaults.standard.bool(forKey: Constants.UserDefault.IsLogin) {
            // Get All audio list and set refrence for Story, Plot and Narration
            APIClient.shared.post(audioReq, feed: .AudioStories) { result in
                ResponseAPI.getResponseArray(result, showAlert: false) { response in
                    var audios = [Audio]()
                    if let audio = response {
                        audio.forEach({ (object) in
                            // Set refrence for Story, Plot and Narration
                            let aud = Audio(object)
                            if isNonStop && aud.Is_nonstop {
                                audios.append(aud)
                            } else if aud.Genre_id == genreId {
                                audios.append(aud)
                            }
                        })
                    }
                    completion(audios)
                }
            }
        } else {
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

    static func getStories(_ completion: @escaping([StoryModel]?) -> Void) {
        APIClient.shared.get("", feed: .Stories) { result in
            ResponseAPI.getResponseArray(result) { response in
                var stories = [StoryModel]()
                if let story = response {
                    story.forEach({ (object) in
                        stories.append(StoryModel(object))
                    })
                }
                completion(stories)
            }
        }
    }
    
    static func getPlots(_ completion: @escaping([StoryModel]?) -> Void) {
        APIClient.shared.get("", feed: .Plots) { result in
            ResponseAPI.getResponseArray(result) { response in
                var plots = [StoryModel]()
                if let plot = response {
                    plot.forEach({ (object) in
                        plots.append(StoryModel(object))
                    })
                }
                completion(plots)
            }
        }
    }
    
    static func getNarrations(_ completion: @escaping([StoryModel]?) -> Void) {
        APIClient.shared.get("", feed: .Narrations) { result in
            ResponseAPI.getResponseArray(result) { response in
                var narrations = [StoryModel]()
                if let narration = response {
                    narration.forEach({ (object) in
                        narrations.append(StoryModel(object))
                    })
                }
                completion(narrations)
            }
        }
    }
    
    static func getAudiosByPlot(_ req: PlotRequest, completion: @escaping([Audio]?) -> Void) {
        APIClient.shared.post(req, feed: .PlotAudioStories) { result in
            ResponseAPI.getResponseArray(result) { response in
                var audios = [Audio]()
                if let data = response {
                    data.forEach { object in
                        audios.append(Audio(object))
                    }
                }
                completion(audios)
            }
        }
    }
    
    static func getAudiosByNarration(_ req: NarrationRequest, completion: @escaping([Audio]?) -> Void) {
        APIClient.shared.post(req, feed: .NarrationAudioStories) { result in
            ResponseAPI.getResponseArray(result) { response in
                var audios = [Audio]()
                if let data = response {
                    data.forEach { object in
                        audios.append(Audio(object))
                    }
                }
                completion(audios)
            }
        }
    }
}

