//
//  HTTPHeader.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//  Copyright © 2022 Durgesh. All rights reserved.
//

import Foundation

enum HTTPHeader {
    
    case contentType(String)
    case accept(String)
    case device(String)
    case authorization(String)

    var header: (field: String, value: String) {
        
        switch self {
        case .contentType(let value): return (field: "Content-Type", value: value)
        case .accept(let value): return (field: "Accept", value: value)
        case .authorization(let value): return (field: "Authorization", value: value)
        case .device(let value): return (field: "Device", value: value)
        }
    }
}
