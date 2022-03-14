//
//  Narration.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

import SwiftyJSON

struct Narration {
    
    init() { }
    init(_ json: JSON) {
    }
}

struct NarrationRequest: Codable {
    var narration_id = Int()
}
