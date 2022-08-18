//
//  APIClient.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//  Copyright © 2022 Durgesh. All rights reserved.
//

import Foundation
import SwiftyJSON

class APIClient: GenericAPIClient {
    static let shared = APIClient()

    var session: URLSession

    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }

    convenience init() {
        self.init(configuration: .default)
    }

    //in the signature of the function in the success case we define the Class type thats is the generic one in the API
    func get(_ query: String, feed: Feed, completion: @escaping (Result<ResponseModel?, APIError>) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Toast.show()
            return
        }
        guard let request = feed.getRequest(query) else { return }
        fetch(with: request, decode: { json -> ResponseModel? in
            guard let apiResponse = json as? ResponseModel else { return  nil }
            return apiResponse
        }, completion: completion)
    }

    func getJson(_ query: String, feed: Feed, completion: @escaping (Result<ResponseModelJSON?, APIError>) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Toast.show()
            return
        }
        guard let request = feed.getRequest(query) else { return }
        fetch(with: request, decode: { json -> ResponseModelJSON? in
            guard let apiResponse = json as? ResponseModelJSON else { return  nil }
            return apiResponse
        }, completion: completion)
    }

    func post<T: Encodable>(_ query: String = "", parameters: T, feed: Feed, completion: @escaping (Result<ResponseModel?, APIError>) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Toast.show()
            return
        }
        guard let request = feed.postRequest(query, parameters: parameters) else { return }
        fetch(with: request, decode: { (json) -> ResponseModel? in
            guard let apiResponse = json as? ResponseModel else { return  nil }
            return apiResponse
        }, completion: completion)
    }

    func postJson<T: Encodable>(_ query: String = "", parameters: T, feed: Feed, completion: @escaping (Result<ResponseModelJSON?, APIError>) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Toast.show()
            return
        }
        guard let request = feed.postRequest(query, parameters: parameters) else { return }
        fetch(with: request, decode: { (json) -> ResponseModelJSON? in
            guard let apiResponse = json as? ResponseModelJSON else { return  nil }
            return apiResponse
        }, completion: completion)
    }

    func delete<T: Encodable>(_ parameters: T, query: String, feed: Feed, completion: @escaping (Result<ResponseModel?, APIError>) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Toast.show()
            return
        }
        guard let request = feed.deleteRequest(query, parameters: parameters) else { return }
        fetch(with: request, decode: { json -> ResponseModel? in
            guard let apiResponse = json as? ResponseModel else { return  nil }
            return apiResponse
        }, completion: completion)
    }

    func deleteJson<T: Encodable>(_ parameters: T, query: String, feed: Feed, completion: @escaping (Result<ResponseModelJSON?, APIError>) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Toast.show()
            return
        }
        guard let request = feed.deleteRequest(query, parameters: parameters) else { return }
        fetch(with: request, decode: { json -> ResponseModelJSON? in
            guard let apiResponse = json as? ResponseModelJSON else { return  nil }
            return apiResponse
        }, completion: completion)
    }

    //Bearer
    func getAuthentication() -> String {
        if let authTokenStr = UserDefaults.standard.value(forKey: Constants.UserDefault.AuthTokenStr) as? String {
            return "Bearer \(authTokenStr)"
        }
        return ""
    }

    func getAuthenticationWithoutBearer() -> String {
        if let authTokenStr = UserDefaults.standard.value(forKey: Constants.UserDefault.AuthTokenStr) as? String {
            return authTokenStr
        }
        return ""
    }

    func GetDeviceInfo() -> String {
        let fcmtoken = UserDefaults.standard.value(forKey: "SenderID")
        let currentDevice = UIDevice.current

        let headerDict = NSMutableDictionary()
        headerDict.setValue(fcmtoken, forKey: "NotificationId")
        headerDict.setValue("", forKey: "AppSignature")
        headerDict.setValue(currentDevice.model, forKey: "Model")
        headerDict.setValue(currentDevice.systemVersion, forKey: "OSVersion")
        headerDict.setValue(currentDevice.systemName, forKey: "OS")
        headerDict.setValue(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String, forKey: "AppVersion")
        headerDict.setValue(self.GenerateAndSaveDeviceId(), forKey: "UUID")
        headerDict.setValue("", forKey: "SerialNo")
        headerDict.setValue("Apple", forKey: "Manufacturer")
        headerDict.setValue("Mobile", forKey: "Platform")
        headerDict.setValue("2", forKey: "AppVersionCode")
        do {
            let data1 = try JSONSerialization.data(withJSONObject: headerDict, options: .prettyPrinted)
            let strdata = String(data: data1, encoding: .utf8)
            return (strdata?.data(using: .utf8)?.base64EncodedString(options: []))!
        } catch {
            return ""
        }
    }

    func GenerateAndSaveDeviceId() -> String {
        let userDefault = UserDefaults.standard
        if (userDefault.value(forKey: "UUID") == nil) {
            userDefault.setValue((UIDevice.current.identifierForVendor?.uuidString)!, forKey: "UUID")
            userDefault.synchronize()
        }
        return userDefault.value(forKey: "UUID") as! String
    }
}

/// ENDPOINT CONFORMANCE
enum Feed {
     //Auth
    case SendOtp
    case VerifyOtp
    case Logout
    case SendOtpProfile
    case VerifyOtpProfile
    case GetProfile
    case UpdateProfileImage
    case RemoveProfileImage
    case UpdateProfileDetails
    case UpdateDeviceToke

    //Preference
    case GetPreference
    case GetPrefCategory
    case UserPreferences
    
    //Genre
    case Genres

    //Audio
    case GuestAudioStories
    case AudioStories
    case AudioStoriesGenre
    case NonStopAudios
    case AddAudioStoryAction
    case EndAudioStoryPlaying
    case AddAudioHistory
    case GetAudioHistory///page=1
    case SurpriseAudio
    case UpdateAudioHistory
    case SearchAudio
    case RecentSearchAudio
    case RemoveSearchAudio
    case RemoveAllSearchAudio
    case FavoriteAudio///page=1
    case AddFavoriteAudio
    case RemoveFavoriteAudio
    case StoryAudioStories
    case PlotAudioStories
    case NarrationAudioStories
    case Stories
    case Plots
    case Narrations
    
    //Other
    case UserStories
    case PostUserStories
    case Feedback
    case AboutUs
    case TermsAndConditions
    case AutoplaySetting
    case NotificationSetting
    case Notification
    case StartUsage
    case EndUsage

    //Trivia
    case TriviaHome
    case TriviaDaily
    case TriviaCategoryPost
    case TriviaPosts
    case TriviaSubmitAnswer
    case TriviaViewAnswer
    case TriviaViewCommnets
    case TriviaAddCommennt
    case TriviaPostView
    case Leaderboard
    
    //Activities
    case ShareActivity
    case UserActivity
    case NotificationActivity
    case UserVideoActivity
    case TriviaAudioActivity
}

protocol CodeEnd {
    var code: Int { get }
}


extension Feed: Endpoint {

    var base: String {
        return Constants.baseURL
    }

    var path: String {
        switch self {
        //Auth
        case .SendOtp:                  return "/api/sendOtp"
        case .VerifyOtp:                return "/api/verifyOtp"
        case .Logout:                   return "/api/logout"
        case .SendOtpProfile:           return "/api/update-profile/sendOtp"
        case .VerifyOtpProfile:         return "/api/update-profile/verifyOtp"
        case .GetProfile:               return "/api/getProfile"
        case .UpdateProfileImage:       return "/api/update-profile/image"
        case .RemoveProfileImage:       return "/api/update-profile/image"
        case .UpdateProfileDetails:     return "/api/update-profile/details"
        case .UpdateDeviceToke:         return "/api/notification/token"

        //Preference
        case .GetPreference:            return "/api/preference-bubbles"
        case .GetPrefCategory:          return "/api/preference-categories"
        case .UserPreferences:          return "/api/user-preferences"
            
        //Genre
        case .Genres:                   return "/api/genres"
        
        //Audio
        case .GuestAudioStories:        return "/api/guest-audio-stories"
        case .AudioStories:             return "/api/audio-stories"
        case .AudioStoriesGenre:        return "/api/audio-stories/genre"
        case .NonStopAudios:            return "/api/audio-stories/non-stop"
        case .AddAudioStoryAction:      return "/api/audio-story/action"
        case .EndAudioStoryPlaying:     return "/api/audio-story/end-playing"
        case .AddAudioHistory:          return "/api/add-audio-history"
        case .GetAudioHistory:          return "/api/get-audio-history"
        case .SurpriseAudio:            return "/api/audio-stories/surprise"
        case .UpdateAudioHistory:       return "/api/update-audio-history"
        case .SearchAudio:              return "/api/search-audio"
        case .RecentSearchAudio:        return "/api/search-audio/recent"
        case .RemoveSearchAudio:        return "/api/search-audio/remove"
        case .RemoveAllSearchAudio:     return "/api/search-audio/remove-all"
        case .FavoriteAudio:            return "/api/favorite-audio/get"
        case .AddFavoriteAudio:         return "/api/favorite-audio/add"
        case .RemoveFavoriteAudio:      return "/api/favorite-audio/remove"
        case .StoryAudioStories:        return "/api/audio-stories/story"
        case .PlotAudioStories:         return "/api/audio-stories/plot"
        case .NarrationAudioStories:    return "/api/audio-stories/narration"
        case .Stories:                  return "/api/stories"
        case .Plots:                    return "/api/plots"
        case .Narrations:               return "/api/narrations"
            
        //Other
        case .UserStories:              return "/api/user-stories"
        case .PostUserStories:          return "/api/user-stories/response"
        case .Feedback:                 return "/api/feedback"
        case .AboutUs:                  return "/api/about-us"
        case .TermsAndConditions:       return "/api/terms-and-conditions"
        case .Notification:             return "/api/notifications"
        case .NotificationSetting:      return "/api/notification"
        case .AutoplaySetting:          return "/api/autoplay"
        case .StartUsage:               return "/api/usage/start"
        case .EndUsage:                 return "/api/usage/end"
            
        //Trivia
        case .TriviaHome:               return "/api/trivia-home"
        case .TriviaDaily:              return "/api/trivia/daily"
        case .TriviaCategoryPost:       return "/api/trivia/category-post"
        case .TriviaPosts:              return "/api/trivia/posts"
        case .TriviaSubmitAnswer:       return "/api/trivia/submit-answer"
        case .TriviaViewAnswer:         return "/api/trivia/view-answer"
        case .TriviaViewCommnets:       return "/api/trivia/view-comments"
        case .TriviaAddCommennt:        return "/api/trivia/add-comment"
        case .TriviaPostView:           return "/api/trivia/posts/view"
        case .Leaderboard:              return "/api/trivia-leader"

        //Activity
        case .ShareActivity:            return "/api/trivia/users/share/activity"
        case .UserActivity:             return "/api/trivia/users/activity"
        case .NotificationActivity:     return "/api/trivia/users/notification/activity"
        case .UserVideoActivity:        return "/api/trivia/users/video/activity"
        case .TriviaAudioActivity:      return "/api/trivia/users/audio/activity"
        }
    }
}
