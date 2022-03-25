//
//  TriviaDaily.swift
//  TaleOMeter
//
//  Created by Durgesh on 14/03/22.
//

import SwiftyJSON

struct TriviaDaily {
    var Title = String()
    var Post_count = Int()
    var Post_count_today = Int()
    var Post_msg = String()
//    var Image = UIImage()
    var ImageUrl = String()

    init() { }
    init(_ json: JSON) {
        Title = json["title"].stringValue
        Post_count = json["post_count"].intValue
        Post_count_today = json["post_count_today"].intValue
        Post_msg = json["post_msg"].stringValue

        if let urlString = json["image"].string {
            ImageUrl = Core.verifyUrl(urlString) ? urlString :   Constants.baseURL.appending("/\(urlString)")
        }
        //.Core.setImage(imageURL, image: &Image)
    }
}
