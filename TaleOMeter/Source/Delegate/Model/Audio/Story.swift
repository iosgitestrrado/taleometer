//
//  Story.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

import SwiftyJSON

struct Story {
    var Id = Int()
    var Name = String()
    var Image = UIImage()
    var Created_at = String()
    var Updated_at = String()
    var Deleted_at = String()
    
    init() { }
    init(_ json: JSON) {
        Id = json["id"].intValue
        Name = json["name"].stringValue
        let imageURL = Constants.baseURL.appending("/\(json["image"].stringValue)")
        Image = UIImage(named: "logo")!
        if let url = URL(string: imageURL) {
            do {
                let data = try Data(contentsOf: url)
                Image = UIImage(data: data) ?? UIImage(named: "logo")!
            } catch { }
        }
        Created_at = json["created_at"].stringValue
        Updated_at = json["updated_at"].stringValue
        Deleted_at = json["deleted_at"].stringValue
    }
}

struct StoryRequest: Codable {
    var plot_id = Int()
    var page = Int()
}
/* {
 "id": 8,
 "name": "Adventure",
 "image": "storage/app/public/story/znKzwtzPD3Exh69vSxGz4Z5dDlVOQ3geVmTOmYWs.jpg",
 "created_at": "2022-03-07T11:24:18.000000Z",
 "updated_at": "2022-03-08T11:40:12.000000Z",
 "deleted_at": null
}*/
