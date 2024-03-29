//
//  AudioClient.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

import Foundation

class AudioClient {
    static func getGenre(_ audioReq: AudioGenreRequest, isNonStop: Bool = false, completion: @escaping([Audio]?) -> Void) {
//        if UserDefaults.standard.bool(forKey: Constants.UserDefault.IsLogin) {
            // Get All audio list and set refrence for Story, Plot and Narration
            APIClient.shared.post(parameters: audioReq, feed: .AudioStoriesGenre) { result in
                ResponseAPI.getResponseArray(result, showAlert: false) { response in
                    var audios = [Audio]()
                    if let audio = response {
                        audio.forEach({ (object) in
                            // Set refrence for Story, Plot and Narration
                            audios.append(Audio(object))
                        })
                    }
                    completion(audios)
                }
            }
//        } else {
//            APIClient.shared.get("", feed: .GuestAudioStories, completion: { result in
//                ResponseAPI.getResponseArray(result) { response in
//                    var audios = [Audio]()
//                    if let audio = response {
//                        audio.forEach({ (object) in
//                            audios.append(Audio(object))
//                        })
//                    }
//                    completion(audios)
//                }
//            })
//        }
    }
    
    static func getNotificationCount(_ completion: @escaping(Int?, Int?) -> Void) {
        APIClient.shared.getJson("", feed: .NotificationCount) { result in
            ResponseAPI.getResponseJson(result, isLogout: false) { response in
                var notification_count = 0
                var chat_count = 0
                if let data = response {
                    if let noti_count = data["notification_count"].int {
                        notification_count = noti_count
                    }
                    if let ch_count = data["chat_count"].int {
                        chat_count = ch_count
                    }
                }
                completion(chat_count, notification_count)
            }
        }
    }
    
    static func getAudios(_ audioReq: AudioRequest, completion: @escaping([Audio]?) -> Void) {
        APIClient.shared.post(parameters: audioReq, feed: .AudioStories) { result in
            ResponseAPI.getResponseArray(result, showAlert: false) { response in
                var audios = [Audio]()
                if let audio = response {
                    audio.forEach({ (object) in
                        // Set refrence for Story, Plot and Narration
                        audios.append(Audio(object))
                    })
                }
                completion(audios)
            }
        }
    }
    
    static func getAudioById(_ storyId: Int, completion: @escaping([Audio]?) -> Void) {
        APIClient.shared.get("\(storyId)", feed: .GetAudioStoryById) { result in
            ResponseAPI.getResponseArray(result, showAlert: false) { response in
                var audios = [Audio]()
                if let audio = response {
                    audio.forEach({ (object) in
                        // Set refrence for Story, Plot and Narration
                        audios.append(Audio(object))
                    })
                }
                completion(audios)
            }
        }
    }
    
    static func getNonstopAudio(_ audioReq: AudioRequest, completion: @escaping([Audio]?, NonStopStatus?) -> Void) {
        APIClient.shared.post(parameters: audioReq, feed: .NonStopAudios) { result in
            ResponseAPI.getResponseArray1(result) { response, jsonObj in
                var nonStopAudios = [Audio]()
                if let audios = response {
                    audios.forEach { object in
                        let nonStopAud = NonStopAudio(object)
                        if nonStopAud.Audio_story.Is_active {
                            nonStopAudios.append(nonStopAud.Audio_story)
                        }
                    }
                }
                var nonStopStatus = NonStopStatus()
                if let nonStatus = jsonObj {
                    nonStopStatus = NonStopStatus(nonStatus)
                }
                completion(nonStopAudios, nonStopStatus)
            }
        }
    }
    
    static func setNonStopActivity(_ req: NonStopActivityReq, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(parameters: req, feed: .NonStopAudioActivity) { result in
            ResponseAPI.getResponseJsonBool(result) { status in
                completion(status)
            }
        }
    }
    
    static func getSurpriseAudio(_ audioReq: AudioRequest, completion: @escaping([Audio]?) -> Void) {
        APIClient.shared.post(parameters: audioReq, feed: .SurpriseAudio) { result in
            ResponseAPI.getResponseArray(result) { response in
                var surAudios = [Audio]()
                if let audios = response {
                    audios.forEach { object in
                        let aud = Audio(object)
                        if aud.Is_active {
                            surAudios.append(aud)
                        }
                    }
                }
                completion(surAudios)
            }
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
    
    static func getAudiosByStory(_ req: StoryRequest, completion: @escaping([Audio]?) -> Void) {
        APIClient.shared.post(parameters: req, feed: .StoryAudioStories) { result in
            ResponseAPI.getResponseArray(result) { response in
                var audios = [Audio]()
//                print(response ?? "te")
                if let data = response {
                    data.forEach { object in
                        let aud = Audio(object)
                        if aud.Is_active {
                            audios.append(aud)
                        }
                    }
                }
                completion(audios)
            }
        }
    }
    
    static func getAudiosByPlot(_ req: PlotRequest, completion: @escaping([Audio]?) -> Void) {
        APIClient.shared.post(parameters: req, feed: .PlotAudioStories) { result in
            ResponseAPI.getResponseArray(result) { response in
                var audios = [Audio]()
                if let data = response {
                    data.forEach { object in
                        let aud = Audio(object)
                        if aud.Is_active {
                            audios.append(aud)
                        }
                    }
                }
                completion(audios)
            }
        }
    }
    
    static func getAudiosByNarration(_ req: NarrationRequest, completion: @escaping([Audio]?) -> Void) {
        APIClient.shared.post(parameters: req, feed: .NarrationAudioStories) { result in
            ResponseAPI.getResponseArray(result) { response in
                var audios = [Audio]()
                if let data = response {
                    data.forEach { object in
                        let aud = Audio(object)
                        if aud.Is_active {
                            audios.append(aud)
                        }
                    }
                }
                completion(audios)
            }
        }
    }
    
    static func addAudioAction(_ req: AddAudioActionRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(parameters: req, feed: .AddAudioStoryAction) { result in
            ResponseAPI.getResponseJsonBool(result, showAlert: false) { status in
                completion(status)
            }
        }
    }
    
    static func endAudioPlaying(_ req: EndAudioRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(parameters: req, feed: .EndAudioStoryPlaying) { result in
            ResponseAPI.getResponseJsonBool(result, showAlert: false) { status in
                completion(status)
            }
        }
    }
}
