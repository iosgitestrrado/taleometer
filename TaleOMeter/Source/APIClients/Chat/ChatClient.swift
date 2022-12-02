//
//  ChatClient.swift
//  TaleOMeter
//
//  Created by Durgesh on 01/12/22.
//

import Foundation

class ChatClient {
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
}
