//
//  ResponseModel.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//  Copyright © 2022 Durgesh. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ResponseModel: Decodable {
    let Status: Bool?
    let Message: String?
    let Data: [JSON]?
}

struct ResponseModelJSON: Codable {
    let Status: Bool?
    let Message: String?
    let Data: JSON?
    let Token: String?
    let New_registeration: String?
}

struct ResponseAPI {

    static func getResponseArray(_ result: Result<ResponseModel?, APIError>, showMessage: Bool, completion: @escaping ([JSON]?, String) -> ()) {
        switch result {
        case .success(let aPIResponse):
            if let response = aPIResponse, let status = response.Status, status, let responseData = response.Data {
                completion(responseData, "")
            } else if let response = aPIResponse, let message = response.Message {
                completion(nil, message)
            } else {
                completion(nil, "Something was so wrong in your request or your handling that the API simply couldn't parse the passed data")
            }
        case .failure(let error):
            completion(nil, error.customDescription)
        }
    }

    static func getResponseJson(_ result: Result<ResponseModelJSON?, APIError>, showMessage: Bool, completion: @escaping (JSON?, String) -> ()) {
        switch result {
        case .success(let aPIResponse):
            if let response = aPIResponse, let status = response.Status, status, let responseData = response.Data {
                completion(responseData, "")
            } else if let response = aPIResponse, let message = response.Message {
                completion(nil, message)
            } else {
                completion(nil, "Something was so wrong in your request or your handling that the API simply couldn't parse the passed data")
            }
        case .failure(let error):
            completion(nil, error.customDescription)
        }
    }
}
