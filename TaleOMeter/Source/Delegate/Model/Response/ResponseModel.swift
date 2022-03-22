//
//  ResponseModel.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//  Copyright © 2022 Durgesh. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

struct ResponseModel: Decodable {
    let status: Bool?
    let message: AnyObject?
    let data: [JSON]?
    
    private enum CodingKeys : String, CodingKey { case status, message, data }
    init(from decoder : Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self.status = try container.decode(Bool.self, forKey: .status)
        } catch {
            self.status = Bool()
        }
        do {
            let type = try container.decode(String.self, forKey: .message)
            self.message = type as AnyObject
        } catch {
            let type = try container.decode(JSON.self, forKey: .message)
            self.message = type as AnyObject
        }
        do {
            self.data = try container.decode([JSON].self, forKey: .data)
        } catch {
            self.data = [JSON]()
        }
    }
}

struct ResponseModelJSON: Decodable {
    let status: Bool?
    let message: AnyObject?
    let data: JSON?
    let token: String?
    let new_registeration: Int?
    
    private enum CodingKeys : String, CodingKey { case status, message, data, token, new_registeration }
    init(from decoder : Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.status = try container.decode(Bool.self, forKey: .status)
        do {
            let type = try container.decode(String.self, forKey: .message)
            self.message = type as AnyObject
        } catch {
            let type = try container.decode(JSON.self, forKey: .message)
            self.message = type as AnyObject
        }
        do {
            self.data = try container.decode(JSON.self, forKey: .data)
        } catch {
            self.data = JSON()
        }
        do {
            self.token = try container.decode(String.self, forKey: .token)
        } catch {
            self.token = String()
        }
        do {
            self.new_registeration = try container.decode(Int.self, forKey: .new_registeration)
        } catch {
            self.new_registeration = 0
        }
    }
}

struct EmptyRequest: Encodable {
    
}

struct ResponseAPI {
    
    static let errorMessage = "Something was so wrong in your request or your handling that the API simply couldn't parse the passed data"
    
    // MARK: check response and parse as per requirement
    static func getResponseArray(_ result: Result<ResponseModel?, APIError>, showAlert: Bool = true, showSuccMessage: Bool = false, completion: @escaping ([JSON]?) -> ()) {
        switch result {
        case .success(let aPIResponse):
            if let response = aPIResponse, let status = response.status, status, let responseData = response.data {
                if showSuccMessage, let msg = response.message as? String {
                    Toast.show(msg)
                }
                completion(responseData)
            } else if let response = aPIResponse, let msg = response.message, (msg is String || msg is JSON) {
                let messageis = getMessageString(msg)
                if messageis.lowercased().contains("unauthorized") {
                    AuthClient.logout(messageis)
                    completion(nil)
                } else {
                    if showAlert {
                        Toast.show(messageis)
                    }
                    completion(nil)
                }
            } else {
                if showAlert {
                    Toast.show(errorMessage)
                }
                completion(nil)
            }
        case .failure(let error):
            if showAlert {
                Toast.show(error.customDescription)
            }
            completion(nil)
        }
    }
    
    static func getResponseJson(_ result: Result<ResponseModelJSON?, APIError>, showAlert: Bool = true, showSuccMessage: Bool = false, completion: @escaping (JSON?) -> ()) {
        switch result {
        case .success(let aPIResponse):
            if let response = aPIResponse, let status = response.status, status, let responseData = response.data {
                if showSuccMessage, let msg = response.message as? String {
                    Toast.show(msg)
                }
                completion(responseData)
            } else if let response = aPIResponse, let msg = response.message, (msg is String || msg is JSON) {
                let messageis = getMessageString(msg)
                if messageis.lowercased().contains("unauthorized") {
                    AuthClient.logout(messageis)
                    completion(nil)
                } else {
                    if showAlert {
                        Toast.show(messageis)
                    }
                    completion(nil)
                }
            } else {
                if showAlert {
                    Toast.show(errorMessage)
                }
                completion(nil)
            }
        case .failure(let error):
            if showAlert {
                Toast.show(error.customDescription)
            }
            completion(nil)
        }
    }
    
    static func getResponseJsonBool(_ result: Result<ResponseModelJSON?, APIError>, showAlert: Bool = true, showSuccMessage: Bool = false, completion: @escaping (Bool) -> ()) {
        switch result {
        case .success(let aPIResponse):
            if let response = aPIResponse, let status = response.status, status {
                if showSuccMessage, let msg = response.message as? String {
                    Toast.show(msg)
                }
                completion(status)
            } else if let response = aPIResponse, let msg = response.message, (msg is String || msg is JSON) {
                let messageis = getMessageString(msg)
                if messageis.lowercased().contains("unauthorized") {
                    AuthClient.logout(messageis)
                    completion(false)
                } else {
                    if showAlert {
                        Toast.show(messageis)
                    }
                    completion(false)
                }
            } else {
                if showAlert {
                    Toast.show(errorMessage)
                }
                completion(false)
            }
        case .failure(let error):
            if showAlert {
                Toast.show(error.customDescription)
            }
            completion(false)
        }
    }
    
    static func getResponseJsonToken(_ result: Result<ResponseModelJSON?, APIError>, showAlert: Bool = true, showSuccMessage: Bool = false, completion: @escaping (JSON?, Bool, String, Bool) -> ()) {
        switch result {
        case .success(let aPIResponse):
            if let response = aPIResponse, let status = response.status, status {
                if let responseData = response.data {
                    if showSuccMessage, let msg = response.message as? String {
                        Toast.show(msg)
                    }
                    completion(responseData, status, response.token ?? "", response.new_registeration == 1)
                } else {
                    completion(nil, status, "", false)
                }
            } else if let response = aPIResponse, let msg = response.message, (msg is String || msg is JSON) {
                let messageis = getMessageString(msg)
                if messageis.lowercased().contains("unauthorized") {
                    AuthClient.logout(messageis)
                    completion(nil, false, "", false)
                } else {
                    if showAlert {
                        Toast.show(messageis)
                    }
                    completion(nil, false, "", false)
                }
            } else {
                if showAlert {
                    Toast.show(errorMessage)
                }
                completion(nil, false, "", false)
            }
        case .failure(let error):
            if showAlert {
                Toast.show(error.customDescription)
            }
            completion(nil, false, "", false)
        }
    }
    
    static func getMessageString(_ messageData: AnyObject) -> String {
        var messageStr = errorMessage
        if let message = messageData as? String {
            return message
        } else if let message = messageData as? JSON {
            for (_, value) in message {
                if let msg = value.string {
                    messageStr = msg
                    break
                } else if let msgArray = value.array, msgArray.count > 0, let msgg =  msgArray[0].string {
                    messageStr = msgg
                    break
                }
            }
        }
        return messageStr
    }
}