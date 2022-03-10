//
//  PreferenceCategory.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

import SwiftyJSON

struct PreferenceCategory {
    var Id = Int()
    var Name = String()
    var Created_at = String()
    var Updated_at = String()
    var Deleted_at = String()
    
    init() { }
    init(_ json: JSON) {
        Id = json["id"].intValue
        Name = json["name"].stringValue
        Created_at = json["created_at"].stringValue
        Updated_at = json["updated_at"].stringValue
        Deleted_at = json["deleted_at"].stringValue
    }
}

/*/{
 "id": 11,
 "name": "Musicians",
 "created_at": "2022-03-07T11:44:39.000000Z",
 "updated_at": "2022-03-07T11:44:39.000000Z",
 "deleted_at": null
},*/
