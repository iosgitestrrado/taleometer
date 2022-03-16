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
    var Image = UIImage()
    
    init() { }
    init(_ json: JSON) {
        Title = json["title"].stringValue
        Post_count = json["post_count"].intValue
        
        var imageURL = ""
        if let urlString = json["image"].string {
            imageURL = Core.verifyUrl(urlString) ? urlString :   Constants.baseURL.appending("/\(urlString)")
        }
        Core.setImage(imageURL, image: &Image)
    }
}
