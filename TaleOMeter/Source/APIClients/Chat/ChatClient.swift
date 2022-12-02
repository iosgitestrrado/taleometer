//
//  ChatClient.swift
//  TaleOMeter
//
//  Created by Durgesh on 01/12/22.
//

import Foundation

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
}
