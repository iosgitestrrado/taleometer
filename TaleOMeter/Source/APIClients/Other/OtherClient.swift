//
//  OtherClient.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

class OtherClient {
    static func getNotifications(_ completion: @escaping([NotificationModel]?) -> Void) {
        APIClient.shared.get("?page=all&limit=2", feed: .Notification) { result in
            ResponseAPI.getResponseArray(result) { response in
                var notifications = [NotificationModel]()
                if let nots = response {
                    nots.forEach { object in
                        notifications.append(NotificationModel(object))
                    }
                }
                completion(notifications)
            }
        }
    }
    
    static func setAutoPlaySetting(_ req: AutoplaySetRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(parameters: req, feed: .AutoplaySetting) { result in
            ResponseAPI.getResponseJsonBool(result, showSuccMessage: true) { status in
                completion(status)
            }
        }
    }
    
    static func setNotificationSetting(_ req: NotificationSetRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(parameters: req, feed: .NotificationSetting) { result in
            ResponseAPI.getResponseJsonBool(result, showSuccMessage: true) { status in
                completion(status)
            }
        }
    }
    
    static func submitFeedback(_ req: FeedbackRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(parameters: req, feed: .Feedback) { result in
            ResponseAPI.getResponseJsonBool(result, showSuccMessage: true) { status in
                completion(status)
            }
        }
    }
    
    static func getStaticContent(_ aboutUs: Bool, completion: @escaping(StaticContent?) -> Void) {
        APIClient.shared.getJson("", feed: aboutUs ? .AboutUs : .TermsAndConditions) { result in
            ResponseAPI.getResponseJson(result) { response in
                var staticContent = StaticContent()
                if let data = response {
                    staticContent = StaticContent(data)
                }
                completion(staticContent)
            }
        }
    }
}
