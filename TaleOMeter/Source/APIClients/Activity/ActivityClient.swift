//
//  ActivityClient.swift
//  TaleOMeter
//
//  Created by Eppancy on 05/07/22.
//

import Foundation

class ActivityClient {
    static func userActivityLog(_ req: UserActivityRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(parameters: req, feed: .UserActivity) { result in
            ResponseAPI.getResponseJsonBool(result, showAlert: false, isLogout: false) { status in
                completion(status)
            }
        }
    }
    
    static func shareActivityLog(_ completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(parameters: ShareActivityRequest(), feed: .ShareActivity) { result in
            ResponseAPI.getResponseJsonBool(result, showAlert: false, isLogout: false) { status in
                completion(status)
            }
        }
    }
    
    static func notificationActivityLog(_ req: NotificationActivityRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(parameters: req, feed: .NotificationActivity) { result in
            ResponseAPI.getResponseJsonBool(result, showAlert: false, isLogout: false) { status in
                completion(status)
            }
        }
    }
    
    static func videoActivityLog(_ req: TriviaVideoActivityRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(parameters: req, feed: .UserVideoActivity) { result in
            ResponseAPI.getResponseJsonBool(result, showAlert: false, isLogout: false) { status in
                completion(status)
            }
        }
    }
    
    static func audioActivityLog(_ req: TriviaVideoActivityRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(parameters: req, feed: .TriviaAudioActivity) { result in
            ResponseAPI.getResponseJsonBool(result, showAlert: false, isLogout: false) { status in
                completion(status)
            }
        }
    }
}
