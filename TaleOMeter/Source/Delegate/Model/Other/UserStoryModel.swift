//
//  UserStoryModel.swift
//  TaleOMeter
//
//  Created by Durgesh on 30/03/22.
//

import SwiftyJSON

struct UserStoryModel {
    var Id = Int()
    var Title = String()
    var TypeT = String()
    var Options = [String]()
    var Order = Int()
    var Created_at = String()
    var Updated_at = String()
    var Deleted_at = String()
    
    var Value = String()
    var Value_Tamil = String()
    var CellId = String()
//    var TextField: UITextField?
    var TextView: UITextView?
    var IsLast = Bool()
    var Title_tamil = String()
    var Options_tamil = [String]()
    
    init() { }
    init(_ json: JSON) {
        Id = json["id"].intValue
        Title = json["title"].stringValue
        Title_tamil = json["title_tamil"].stringValue
        TypeT = json["type"].stringValue
        CellId = TypeT.lowercased() == "text" ? "textViewCell" : (TypeT.lowercased() == "radio" ? "radioCell" : "optionCell")//radio, choice
        if let opt =  json["options"].string {
            let data = Data(opt.utf8)
            do {
                let arr = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String]
                Options = arr
                if Options.count > 0 {
                    Value = Options[0]
                }
                //print(array) // ["one", "two", "three"]
            } catch {
                //print(error)
            }
        }
        
        if let opt =  json["options_tamil"].string {
            let data = Data(opt.utf8)
            do {
                let arr = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String]
                Options_tamil = arr
                if Options_tamil.count > 0 {
                    Value_Tamil = Options_tamil[0]
                }
                //print(array) // ["one", "two", "three"]
            } catch {
                //print(error)
            }
        }
        
        Order = json["order"].intValue
        Created_at = json["created_at"].stringValue
        Updated_at = json["updated_at"].stringValue
        Deleted_at = json["deleted_at"].stringValue
    }
}

/* {
 "id": 18,
 "title": "story test",
 "type": "text",
 "options": null,
 "order": null,
 "created_at": "2022-03-16T11:48:25.000000Z",
 "updated_at": "2022-03-16T11:48:25.000000Z",
 "deleted_at": null
}*/

struct UserStoryRequest: Codable {
    var user_story_ids = [Int]()
    var values = [String]()
}
