//
//  ChatModel.swift
//  TaleOMeter
//
//  Created by Durgesh on 02/12/22.
//

import SwiftyJSON

class ChatModel {
    var Chat_id = Int()
    var Reciever_id = Int()
    var Reciever_name = String()
    var Logo = String()
    var Unread_msg = false
    
    init() {    }
    init(_ json: JSON) {
        Chat_id = json["chat_id"].intValue
        Reciever_id = json["reciever_id"].intValue
        Reciever_name = json["reciever_name"].stringValue
        Logo = json["logo"].stringValue
        if let unreadmsg = json["unread_msg"].int, unreadmsg == 1 {
            Unread_msg = true
        }
    }
}

class MessageModel {
    var Reciever_name = String()
    var Logo = String()
    var Chat_id = Int()
    var Reciever_id = Int()
    var Messages = [MessageData]()

    init() {    }
    init(_ json: JSON) {
        Reciever_name = json["reciever_name"].stringValue
        Logo = json["logo"].stringValue
        Chat_id = json["chat_id"].intValue
        Reciever_id = json["reciever_id"].intValue
        if let msgs = json["messages"].array, msgs.count > 0 {
            msgs.forEach { object in
                Messages.append(MessageData(object))
            }
        }
    }
}

class MessageData {
    var Day = String()
    var Chats = [ChatData]()
   
    init() {    }
    init(_ json: JSON) {
        Day = json["day"].stringValue
        if let chats = json["chats"].array, chats.count > 0 {
            chats.forEach { object in
                Chats.append(ChatData(object))
            }
        }
    }
}

class ChatData {
    var Align = String()
    var Chat_date = String()
    var Read_status = false
    var Created_at = String()
    var Chat_time = String()
    var From = String()
    var Image = String()
    var Me = false
    var Message = String()
    var Chat_type = String()
    
    init() {    }
    init(_ json: JSON) {
        Align = json["align"].stringValue
        Chat_date = json["chat_date"].stringValue
        if let readStatus = json["read_status"].int, readStatus == 1 {
            Read_status = true
        }
        Created_at = json["created_at"].stringValue
        Chat_time = json["chat_time"].stringValue
        From = json["from"].stringValue
        Image = json["image"].stringValue
        if let meme = json["me"].int, meme == 1 {
            Me = true
        }
        Message = json["message"].stringValue
        Chat_type = json["chat_type"].stringValue
    }
}

struct SendMessageRequest: Codable {
    var message = String()
    var reciever_id = 1
}
