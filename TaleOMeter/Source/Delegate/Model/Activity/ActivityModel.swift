//
//  ActivityModel.swift
//  TaleOMeter
//
//  Created by Eppancy on 05/07/22.
//

import Foundation

struct ShareActivityRequest: Encodable {
    var is_shared = 1
}

struct UserActivityRequest: Encodable {
    var post_id = String()
    var category_id = String()
    var screen_name = String()
    var type = String()
}

struct NotificationActivityRequest: Encodable {
    var post_id = Int()
    var category_id = Int()
    var screen_name = String()
    var is_open = 1
    var type = String()
}

struct TriviaVideoActivityRequest: Encodable {
    var post_id = Int()
    var duration = String()
    var time = String()
    var status = String()
    var is_notification = Int()
    var type = "trivia"
}
