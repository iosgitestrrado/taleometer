//
//  TriviaPost.swift
//  TaleOMeter
//
//  Created by Durgesh on 14/03/22.
//

import SwiftyJSON
import UIKit

struct TriviaPost {
    var Post_id = Int()
    var Category_id = Int()
    var Category_name = String()
    var Question = String()
    var Value = String()
    var Question_type = String()
    var Question_media = UIImage()
    var QuestionVideoURL = String()
    var User_opened = Bool()
    var User_opened_status = Int()
    
    var IsExpanded = false
    var Comments = [TriviaComment]()

    init() { }
    init(_ json: JSON) {
        Post_id = json["post_id"].intValue
        Category_id = json["category_id"].intValue
        Category_name = json["category_name"].stringValue
        Question = json["question"].stringValue
        Question_type = json["question_type"].stringValue
        User_opened = json["user_opened"].boolValue
        User_opened_status = json["user_opened_status"].intValue
        
        var imageURL = ""
        if let urlString = json["question_media"].string, Question_type.lowercased() == "image" {
            imageURL = Core.verifyUrl(urlString) ? urlString :  Constants.baseURL.appending("/\(urlString)")
            Core.setImage(imageURL, image: &Question_media)
        } else {
            QuestionVideoURL = json["question_media"].stringValue
            Question_media = UIImage(named: "acastro_180403_1777_youtube_0001") ?? defaultImage
        }
    }
}
