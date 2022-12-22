//
//  OtherClient.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

import Darwin

class OtherClient {
    static func getNotifications(_ page: Int, limit: Int, noti_type: String, completion: @escaping([NotificationModel]?) -> Void) {
        APIClient.shared.get("?page=\(page)&limit=\(limit)&notify_type=\(noti_type)", feed: .Notification) { result in
            ResponseAPI.getResponseArray(result, showAlert: false) { response in
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
    
    static func updateNotification(_ req: NotificationUpdateRequest, showSuccMessage: Bool, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(parameters: req, feed: .UpdateNotification) { result in
            ResponseAPI.getResponseJsonBool(result, showSuccMessage: showSuccMessage) { status in
                completion(status)
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
            ResponseAPI.getResponseJsonBool(result) { status in
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
    
    static func getUserStory(_ completion: @escaping([UserStoryModel]?) -> Void) {
        APIClient.shared.get("", feed: .UserStories) { result in
            ResponseAPI.getResponseArray(result) { response in
                var stories = [UserStoryModel]()
                if let strs = response {
                    strs.forEach { object in
                        stories.append(UserStoryModel(object))
                    }
                }
                completion(stories)
            }
        }
    }
    
    static func postUserStory(_ req: UserStoryRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(parameters: req, feed: .PostUserStories) { result in
            ResponseAPI.getResponseJsonBool(result) { status in
                completion(status)
            }
        }
    }
    
    static func startUsage(_ req: StartUsageRequest, completion: @escaping(UsageModel?) -> Void) {
        APIClient.shared.postJson(parameters: req, feed: .StartUsage) { result in
            ResponseAPI.getResponseJson(result, showAlert: false) { response in
                var startUsage = UsageModel()
                if let data = response {
                    startUsage = UsageModel(data)
                }
                completion(startUsage)
            }
        }
    }
    
    static func endUsage(_ req: EndUsageRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(parameters: req, feed: .EndUsage) { result in
            ResponseAPI.getResponseJsonBool(result, showAlert: false) { status in
                completion(status)
            }
        }
    }
    
    static func getFAQ(_ completion: @escaping([FAQModel]?) -> Void) {
        APIClient.shared.get("", feed: .FAQ) { result in
            ResponseAPI.getResponseArray(result) { response in
                var faqs = [FAQModel]()
                if let strs = response {
                    strs.forEach { object in
                        faqs.append(FAQModel(object))
                    }
                }
                completion(faqs)
            }
        }
    }
}
