//
//  TriviaAnswer.swift
//  TaleOMeter
//
//  Created by Durgesh on 14/03/22.
//

import SwiftyJSON

struct TriviaAnswer {
    
    var Post_id = Int()
    var Category_id = Int()
    var Answer_type = String()
    //var Answer_image = UIImage()
    var Answer_image_url = String()
    var Answer_text = String()
    var User_opened = Bool()
    
    init() { }
    init(_ json: JSON) {
        
        Post_id = json["post_id"].intValue
        Category_id = json["category_id"].intValue
        Answer_type = json["answer_type"].stringValue
        
        if let urlString = json["answer_image"].string {
            Answer_image_url = Core.verifyUrl(urlString) ? urlString :   Constants.baseURL.appending("/\(urlString)")
        }
//        Core.setImage(imageURL, image: &Answer_image)
        Answer_text = json["answer_text"].stringValue
        User_opened = json["user_opened"].boolValue
    }
}

/* {
 "post_id": 1,
 "category_id": 8,
 "answer_type": "text",
 "answer_image": "",
 "answer_text": "cartoon",
 "user_opened": true
}*/

struct SubmitAnswerRequest: Encodable {
    var post_id = Int()
    var answer = String()
}

struct PostIdRequest: Encodable {
    var post_id = Int()
}
