//
//  ChatClient.swift
//  TaleOMeter
//
//  Created by Durgesh on 01/12/22.
//

import Foundation
import SwiftyJSON

class ChatClient {
    static func getChatLists(_ completion: @escaping([ChatModel]?) -> Void) {
        APIClient.shared.postJson(parameters: EmptyRequest(), feed: .ChatList) { result in
            ResponseAPI.getResponseJson(result) { response in
                var chatList = [ChatModel]()
                if let data = response, let arrIn = data["list"].array, arrIn.count > 0 {
                    arrIn.forEach { object in
                        chatList.append(ChatModel(object))
                    }
                }
                completion(chatList)
            }
        }
    }
    
    static func getMessages(_ completion: @escaping(MessageModel?) -> Void) {
        APIClient.shared.postJson(parameters: EmptyRequest(), feed: .ChatMessage) { result in
            ResponseAPI.getResponseJson(result) { response in
                var msgModel: MessageModel?
                if let data = response, let messages = data["messages"].dictionary {
                    msgModel = MessageModel(JSON(messages))
                }
                completion(msgModel)
            }
        }
    }
    
    static func sendMessage(_ request: SendMessageRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(parameters: request, feed: .SendMessage) { result in
            ResponseAPI.getResponseJsonBool(result, showAlert: true) { response in
                completion(response)
            }
        }
    }
}
