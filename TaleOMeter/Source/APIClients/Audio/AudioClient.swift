//
//  AudioClient.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

import Foundation

class AudioClient {
    static func get(_ audioReq: AudioRequest, genreId: Int, completion: @escaping([Audio]?) -> Void) {
        var stories = [Story]()
        var plots = [Story]()
        var narrations = [Story]()
        if UserDefaults.standard.bool(forKey: Constants.UserDefault.IsLogin) {
            // Get all stories
            self.getStories { storyList in
                if let storyArr = storyList {
                    stories = storyArr
                }
                
                // Get all Plots
                self.getPlots { plotList in
                    if let plotArr = plotList {
                        plots = plotArr
                    }
                    
                    // Get all narrations
                    self.getNarrations { narrationList in
                        if let narrationArr = narrationList {
                            narrations = narrationArr
                        }
                        
                        // Get All audio list and set refrence for Story, Plot and Narration
                        APIClient.shared.post(audioReq, feed: .AudioStories) { result in
                            ResponseAPI.getResponseArray(result) { response in
                                var audios = [Audio]()
                                if let audio = response {
                                    audio.forEach({ (object) in
                                        // Set refrence for Story, Plot and Narration
                                        let aud = Audio(object, strories: stories, plots: plots, narrations: narrations)
                                        if aud.Genre_id == genreId {
                                            audios.append(aud)
                                        }
                                    })
                                }
                                completion(audios)
                            }
                        }
                    }
                }
            }
        } else {
            APIClient.shared.get("", feed: .GuestAudioStories, completion: { result in
                ResponseAPI.getResponseArray(result) { response in
                    var audios = [Audio]()
                    if let audio = response {
                        audio.forEach({ (object) in
                            let aud = Audio(object, strories: stories, plots: plots, narrations: narrations)
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

    static func getStories(_ completion: @escaping([Story]?) -> Void) {
        APIClient.shared.get("", feed: .Stories) { result in
            ResponseAPI.getResponseArray(result) { response in
                var stories = [Story]()
                if let story = response {
                    story.forEach({ (object) in
                        stories.append(Story(object))
                    })
                }
                completion(stories)
            }
        }
    }
    
    static func getPlots(_ completion: @escaping([Story]?) -> Void) {
        APIClient.shared.get("", feed: .Stories) { result in
            ResponseAPI.getResponseArray(result) { response in
                var plots = [Story]()
                if let plot = response {
                    plot.forEach({ (object) in
                        plots.append(Story(object))
                    })
                }
                completion(plots)
            }
        }
    }
    
    static func getNarrations(_ completion: @escaping([Story]?) -> Void) {
        APIClient.shared.get("", feed: .Stories) { result in
            ResponseAPI.getResponseArray(result) { response in
                var narrations = [Story]()
                if let narration = response {
                    narration.forEach({ (object) in
                        narrations.append(Story(object))
                    })
                }
                completion(narrations)
            }
        }
    }
}

