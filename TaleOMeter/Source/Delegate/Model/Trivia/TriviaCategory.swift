//
//  TriviaCategory.swift
//  TaleOMeter
//
//  Created by Durgesh on 14/03/22.
//

import SwiftyJSON

struct TriviaCategory {
    var Post_id = Int()
    var Category_id = Int()
    var Category_name = String()
    var Post_count = Int()
    var Category_image = UIImage()

    init() { }
    init(_ json: JSON) {
        Post_id = json["post_id"].intValue
        Category_id = json["category_id"].intValue
        Category_name = json["category_name"].stringValue
        Post_count = json["post_count"].intValue
        
        var imageURL = ""
        if let urlString = json["category_image"].string {
            imageURL = Core.verifyUrl(urlString) ? urlString :   Constants.baseURL.appending("/\(urlString)")
        }
        Core.setImage(imageURL, image: &Category_image)
    }
}

struct TriviaCategoryRequest: Encodable {
    var category = Int()
}

/*
 "category_id": 10,
 "category_name": "Fantasy movies",
 "post_count": 0,
 "category_image": "https://dev-taleometer.estrradoweb.com/storage/app/public/trivia_category/0mkVz1xyroE2KUr8n1dnw5vaDVSCGLi2fa2ZEQ0r.jpg"
}*/
