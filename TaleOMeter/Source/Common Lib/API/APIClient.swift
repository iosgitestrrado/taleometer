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
        guard let request = feed.getRequest(query, headers: [HTTPHeader.contentType("application/json"), HTTPHeader.device(GetDeviceInfo()), HTTPHeader.authorization(getAuthentication())]) else { return }
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
        guard let request = feed.getRequest(query, headers: [HTTPHeader.contentType("application/json"), HTTPHeader.device(GetDeviceInfo()), HTTPHeader.authorization(getAuthentication())]) else { return }
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
        guard let request = feed.postRequest(query, parameters: parameters, headers: [HTTPHeader.contentType("application/json"), HTTPHeader.device(GetDeviceInfo()), HTTPHeader.authorization(getAuthentication())]) else { return }
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
        guard let request = feed.postRequest(query, parameters: parameters, headers: [HTTPHeader.contentType("application/json"), HTTPHeader.device(GetDeviceInfo()), HTTPHeader.authorization(getAuthentication())]) else { return }
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
        guard let request = feed.postRequest(parameters, headers: [HTTPHeader.contentType("application/json"), HTTPHeader.device(GetDeviceInfo()), HTTPHeader.authorization(getAuthentication())]) else { return }
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
        guard let request = feed.postRequest(parameters, headers: [HTTPHeader.contentType("application/json"), HTTPHeader.device(GetDeviceInfo()), HTTPHeader.authorization(getAuthentication())]) else { return }
        fetch(with: request, decode: { (json) -> ResponseModelJSON? in
            guard let apiResponse = json as? ResponseModelJSON else { return  nil }
            return apiResponse
        }, completion: completion)
    }

    func delete(_ query: String, feed: Feed, completion: @escaping (Result<ResponseModel?, APIError>) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Snackbar.showErrorMessage("Please check your Internet connetction! and Try again!")
            return
        }
        guard let request = feed.getDeleteRequest(query, headers: [HTTPHeader.contentType("application/json"), HTTPHeader.device(GetDeviceInfo()), HTTPHeader.authorization(getAuthentication())]) else { return }
        fetch(with: request, decode: { json -> ResponseModel? in
            guard let apiResponse = json as? ResponseModel else { return  nil }
            return apiResponse
        }, completion: completion)
    }

    func deleteJson(_ query: String, feed: Feed, completion: @escaping (Result<ResponseModelJSON?, APIError>) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Snackbar.showErrorMessage("Please check your Internet connetction! and Try again!")
            return
        }
        guard let request = feed.getDeleteRequest(query, headers: [HTTPHeader.contentType("application/json"), HTTPHeader.device(GetDeviceInfo()), HTTPHeader.authorization(getAuthentication())]) else { return }
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

    static func getBaseURL() -> String {
        return Constants.baseURL
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
    case ProfileImage
    case ProfileDetails

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
}

protocol CodeEnd {
    var code: Int { get }
}


extension Feed: Endpoint {

    var base: String {
        return APIClient.getBaseURL()
    }

    var path: String {
        switch self {
        //Auth
        case .SendOtp:                  return "\(APIClient.basePathAuth)/sendOtp"
        case .VerifyOtp:                return "\(APIClient.basePathAuth)/verifyOtp"
        case .Logout:                   return "\(APIClient.basePathAuth)/logout"
        case .SendOtpProfile:           return "\(APIClient.basePathAuth)/update-profile/sendOtp"
        case .VerifyOtpProfile:         return "\(APIClient.basePathAuth)/update-profile/verifyOtp"
        case .GetProfile:               return "\(APIClient.basePathAuth)/getProfile"
        case .ProfileImage:             return "\(APIClient.basePathAuth)/update-profile/image"
        case .ProfileDetails:           return "\(APIClient.basePathAuth)/update-profile/details"

        //Preference
        case .GetPreference:            return "\(APIClient.basePathGeneral)/preference-bubbles"
        case .GetPrefCategory:          return "\(APIClient.basePathGeneral)/preference-categories"
        case .UserPreferences:          return "\(APIClient.basePathGeneral)/user-preferences"
            
        //Genre
        case .Genres:                   return "\(APIClient.basePathGeneral)/genres"
        
        //Audio
        case .GuestAudioStories:        return "\(APIClient.basePathGeneral)/guest-audio-stories"
        case .AudioStories:             return "\(APIClient.basePathGeneral)/audio-stories"
        case .AddAudioHistory:          return "\(APIClient.basePathStock)/add-audio-history"
        case .GetAudioHistory:          return "\(APIClient.basePathStock)/get-audio-history"
        case .UpdateAudioHistory:       return "\(APIClient.basePathStock)/update-audio-history"
        case .SearchAudio:              return "\(APIClient.basePathStock)/search-audio"
        case .RecentSearchAudio:        return "\(APIClient.basePathStock)/search-audio/recent"
        case .RemoveSearchAudio:        return "\(APIClient.basePathStock)/search-audio/remove"
        case .RemoveAllSearchAudio:     return "\(APIClient.basePathStock)/search-audio/remove-all"
        case .FavoriteAudio:            return "\(APIClient.basePathStock)/favorite-audio/get"
        case .AddFavoriteAudio:         return "\(APIClient.basePathStock)/favorite-audio/add"
        case .RemoveFavoriteAudio:      return "\(APIClient.basePathStock)/favorite-audio/remove"
        case .PlotAudioStories:         return "\(APIClient.basePathStock)/audio-stories/plot"
        case .NarrationAudioStories:    return "\(APIClient.basePathStock)/audio-stories/narration"
        case .Stories:                  return "\(APIClient.basePathStock)/stories"
        case .Plots:                    return "\(APIClient.basePathStock)/plots"
        case .Narrations:               return "\(APIClient.basePathStock)/narrations"
            
        //Other
        case .UserStories:              return "\(APIClient.basePathStock)/user-stories"
        }
    }
}
