//
//  StoryModel.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

import SwiftyJSON

struct StoryModel {
    var Id = Int()
    var Name = String()
//    var Image = UIImage()
    var ImageUrl = String()
    var CoverImageUrl = String()
    var Created_at = String()
    var Updated_at = String()
    var Deleted_at = String()
    
    init() { }
    init(_ json: JSON) {
        Id = json["id"].intValue
        Name = json["name"].stringValue
        //Core.setImage(Constants.baseURL.appending("/\(json["image"].stringValue)"), image: &Image)
        //ImageUrl = Constants.baseURL.appending("/\(json["image"].stringValue)")
        if let urlString = json["image"].string {
            ImageUrl = Core.verifyUrl(urlString) ? urlString : Constants.baseURL.appending("/\(urlString)")
        }
        if let urlString = json["cover_image"].string {
            CoverImageUrl = Core.verifyUrl(urlString) ? urlString : Constants.baseURL.appending("/\(urlString)")
        }
        Created_at = json["created_at"].stringValue
        Updated_at = json["updated_at"].stringValue
        Deleted_at = json["deleted_at"].stringValue
    }
}

struct StoryRequest: Codable {
    var story_id = Int()
    var shuffle = Int()
    var page = String()
    var limit = Int()
}

struct PlotRequest: Codable {
    var plot_id = Int()
    var shuffle = Int()
    var page = String()
    var limit = Int()
}

struct NarrationRequest: Codable {
    var narration_id = Int()
    var shuffle = Int()
    var page = String()
    var limit = Int()
}
/* {
 "id": 8,
 "name": "Adventure",
 "image": "storage/app/public/story/znKzwtzPD3Exh69vSxGz4Z5dDlVOQ3geVmTOmYWs.jpg",
 "created_at": "2022-03-07T11:24:18.000000Z",
 "updated_at": "2022-03-08T11:40:12.000000Z",
 "deleted_at": null
}*/
