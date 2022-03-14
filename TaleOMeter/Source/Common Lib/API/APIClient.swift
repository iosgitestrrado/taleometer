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
    static let basePathSBT = "/api/v1/EducationalVideos"
    static let basePathWL = "/api/v1/WatchList"
    static let basePathPort = "/api/v1/Portfolio"
    static let basePathStock = "/api/v1/Stock"
    static let basePathGeneral = "/api/v1/General"
    static let basePathAuth = "/api/v1/Auth"
    static let basePathProPlan = "/api/v1/Proplan"
    static let basePathProCode = "/api/v1/PromoCode"
    static let basePathProfile = "/api/v1/Profile"

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
            Snackbar.showErrorMessage("Please check your Internet connetction! and Try again!")
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
            Snackbar.showErrorMessage("Please check your Internet connetction! and Try again!")
            return
        }
        guard let request = feed.getRequest(query) else { return }
        fetch(with: request, decode: { json -> ResponseModelJSON? in
            guard let apiResponse = json as? ResponseModelJSON else { return  nil }
            return apiResponse
        }, completion: completion)
    }

    func post<T: Encodable>(_ query: String, parameters: T, feed: Feed, completion: @escaping (Result<ResponseModel?, APIError>) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Snackbar.showErrorMessage("Please check your Internet connetction! and Try again!")
            return
        }
        guard let request = feed.postRequest(query, parameters: parameters) else { return }
        fetch(with: request, decode: { (json) -> ResponseModel? in
            guard let apiResponse = json as? ResponseModel else { return  nil }
            return apiResponse
        }, completion: completion)
    }

    func postJson<T: Encodable>(_ query: String, parameters: T, feed: Feed, completion: @escaping (Result<ResponseModelJSON?, APIError>) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Snackbar.showErrorMessage("Please check your Internet connetction! and Try again!")
            return
        }
        guard let request = feed.postRequest(query, parameters: parameters) else { return }
        fetch(with: request, decode: { (json) -> ResponseModelJSON? in
            guard let apiResponse = json as? ResponseModelJSON else { return  nil }
            return apiResponse
        }, completion: completion)
    }

    func post<T: Encodable>(_ parameters: T, feed: Feed, completion: @escaping (Result<ResponseModel?, APIError>) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Snackbar.showErrorMessage("Please check your Internet connetction! and Try again!")
            return
        }
        guard let request = feed.postRequest("", parameters: parameters) else { return }
        fetch(with: request, decode: { (json) -> ResponseModel? in
            guard let apiResponse = json as? ResponseModel else { return  nil }
            return apiResponse
        }, completion: completion)
    }

    func postJson<T: Encodable>(_ parameters: T, feed: Feed, completion: @escaping (Result<ResponseModelJSON?, APIError>) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Snackbar.showErrorMessage("Please check your Internet connetction! and Try again!")
            return
        }
        guard let request = feed.postRequest("", parameters: parameters) else { return }
        fetch(with: request, decode: { (json) -> ResponseModelJSON? in
            guard let apiResponse = json as? ResponseModelJSON else { return  nil }
            return apiResponse
        }, completion: completion)
    }

    func delete<T: Encodable>(_ parameters: T, query: String, feed: Feed, completion: @escaping (Result<ResponseModel?, APIError>) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Snackbar.showErrorMessage("Please check your Internet connetction! and Try again!")
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
            Snackbar.showErrorMessage("Please check your Internet connetction! and Try again!")
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
    case UpdateProfileDetails

    //Preference
    case GetPreference
    case GetPrefCategory
    case UserPreferences
    
    //Genre
    case Genres

    //Audio
    case GuestAudioStories
    case AudioStories
    case AddAudioHistory
    case GetAudioHistory///page=1
    case UpdateAudioHistory
    case SearchAudio
    case RecentSearchAudio
    case RemoveSearchAudio
    case RemoveAllSearchAudio
    case FavoriteAudio///page=1
    case AddFavoriteAudio
    case RemoveFavoriteAudio
    case PlotAudioStories
    case NarrationAudioStories
    case Stories
    case Plots
    case Narrations
    
    //Other
    case UserStories
    
    //Trivia
    case TriviaHome
    case TriviaDaily
    case TriviaCategoryPost
    case TriviaPosts
    case TriviaSubmitAnswer
    case TriviaViewAnswer
    case TriviaViewCommnets
    case TriviaAddCommennt
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
        case .UpdateProfileDetails:     return "/api/update-profile/details"

        //Preference
        case .GetPreference:            return "/api/preference-bubbles"
        case .GetPrefCategory:          return "/api/preference-categories"
        case .UserPreferences:          return "/api/user-preferences"
            
        //Genre
        case .Genres:                   return "/api/genres"
        
        //Audio
        case .GuestAudioStories:        return "/api/guest-audio-stories"
        case .AudioStories:             return "/api/audio-stories"
        case .AddAudioHistory:          return "/api/add-audio-history"
        case .GetAudioHistory:          return "/api/get-audio-history"
        case .UpdateAudioHistory:       return "/api/update-audio-history"
        case .SearchAudio:              return "/api/search-audio"
        case .RecentSearchAudio:        return "/api/search-audio/recent"
        case .RemoveSearchAudio:        return "/api/search-audio/remove"
        case .RemoveAllSearchAudio:     return "/api/search-audio/remove-all"
        case .FavoriteAudio:            return "/api/favorite-audio/get"
        case .AddFavoriteAudio:         return "/api/favorite-audio/add"
        case .RemoveFavoriteAudio:      return "/api/favorite-audio/remove"
        case .PlotAudioStories:         return "/api/audio-stories/plot"
        case .NarrationAudioStories:    return "/api/audio-stories/narration"
        case .Stories:                  return "/api/stories"
        case .Plots:                    return "/api/plots"
        case .Narrations:               return "/api/narrations"
            
        //Other
        case .UserStories:              return "/api/user-stories"
            
        //Trivia
        case .TriviaHome:               return "/api/trivia-home"
        case .TriviaDaily:              return "/api/trivia/daily"
        case .TriviaCategoryPost:       return "/api/trivia/category-post"
        case .TriviaPosts:              return "/api/trivia/posts"
        case .TriviaSubmitAnswer:       return "/api/trivia/submit-answer"
        case .TriviaViewAnswer:         return "/api/trivia/view-answer"
        case .TriviaViewCommnets:       return "/api/trivia/view-comments"
        case .TriviaAddCommennt:        return "/api/trivia/add-comment"
        }
    }
}
