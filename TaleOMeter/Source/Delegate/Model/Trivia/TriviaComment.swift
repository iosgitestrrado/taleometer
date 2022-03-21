//
//  TriviaComment.swift
//  TaleOMeter
//
//  Created by Durgesh on 14/03/22.
//

import SwiftyJSON
import UIKit

struct TriviaComment {
    private let personImage = UIImage(named: "person")!
    
    var Comment_id = Int()
    var Post_id = Int()
    var You = Int()
    var User_name = String()
    var Is_answer = Bool()
    var Comment = String()
    var Time_ago = String()
    var Reply_count = Int()
    var Profile_image = UIImage()
    var Reply = [TriviaComment]()
    
    var IsExpanded = false
    
    init() { }
    init(_ json: JSON) {
        Comment_id = json["comment_id"].intValue
        Post_id = json["post_id"].intValue
        You = json["you"].intValue
        User_name = json["user_name"].stringValue
        Is_answer = json["is_answer"].boolValue
        Comment = json["comment"].stringValue
        Time_ago = json["time_ago"].stringValue
        Reply_count = json["reply_count"].intValue
        
        var imageURL = ""
        if let urlString = json["profile_image"].string {
            imageURL = Core.verifyUrl(urlString) ? urlString :   Constants.baseURL.appending("/\(urlString)")
        }
        if let url = URL(string: imageURL) {
            do {
                let data = try Data(contentsOf: url)
                Profile_image = UIImage(data: data) ?? personImage
            } catch {
                Profile_image = personImage
            }
        } else {
            Profile_image = personImage
        }
//        Core.setImage(imageURL, image: &Profile_image)
        
        if let reply = json["reply"].array {
            reply.forEach { (object) in
                Reply.append(TriviaComment(object))
            }
        }
        
    }
}

struct AddCommentRequest: Encodable {
    var post_id = Int()
    var comment_id: Int?
    var comment = String()
}

/*
 "comment_id": 8,
 "post_id": 1,
 "you": 0,
 "user_name": "Agent ",
 "is_answer": 1,
 "comment": "Yes",
 "time_ago": "21 hours ago",
 "reply_count": 0,
 "reply": []*/
