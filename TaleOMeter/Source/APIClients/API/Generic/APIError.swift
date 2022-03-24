//
//  APIError.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//  Copyright © 2022 Durgesh. All rights reserved.
//

import Foundation

enum APIError: Error {
    
    case invalidData
    case jsonDecodingFailure
    case responseUnsuccessful(_ description: String)
    case decodingTaskFailure(_ description: String)
    case requestFailed(_ description: String)
    case jsonConversionFailure(_ description: String)
    case postParametersEncodingFalure(_ description: String)
    case applVersionNotvalid(_ description: String)

    var customDescription: String {
        switch self {
        case .requestFailed(let description): return "Error: \(description)"
        case .invalidData: return "Invalid Data"
        case .responseUnsuccessful(let description): return "Error: \(description)"
        case .jsonDecodingFailure: return "Error - JSON decoding Failure"
        case .jsonConversionFailure(let description): return "Error: \(description)"
        case .decodingTaskFailure(let description): return "Error: \(description)"
        case .postParametersEncodingFalure(let description): return "Error: \(description)"
        case .applVersionNotvalid(let description): return "\(description)"
        }
    }
}
