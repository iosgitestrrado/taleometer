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
    var Name = String()
    var Display_name = String()
    var Email = String()
}
