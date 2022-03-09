//
//  Genre.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

import SwiftyJSON

struct Genre {
    var Id = Int()
    var Name = String()
    var Is_active = Bool()
    var Created_at = String()
    var Updated_at = String()
    var Deleted_at = String()
    
    init() { }
    init(_ json: JSON) {
        Id = json["id"].intValue
        Name = json["name"].stringValue
        Is_active = json["is_active"].boolValue
        Created_at = json["created_at"].stringValue
        Updated_at = json["updated_at"].stringValue
        Deleted_at = json["deleted_at"].stringValue
    }
}

/* {
 "id": 24,
 "name": "Entertain",
 "is_active": 1,
 "created_at": "2022-03-03T08:24:06.000000Z",
 "updated_at": "2022-03-04T11:59:30.000000Z",
 "deleted_at": null
},*/
