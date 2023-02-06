//
//  Profile.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

import SwiftyJSON

struct Profile {
    
    init() { }
    init(_ json: JSON) {
    }
}


struct ProfileRequest: Encodable {
    var name = String()
    var display_name = String()
    var email = String()
}
