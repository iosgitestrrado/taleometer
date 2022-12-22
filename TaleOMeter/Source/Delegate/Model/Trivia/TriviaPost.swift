//
//  TriviaPost.swift
//  TaleOMeter
//
//  Created by Durgesh on 14/03/22.
//

import SwiftyJSON
import UIKit
import AVFoundation

struct TriviaPost {
    var Post_id = Int()
    var Category_id = Int()
    var Category_name = String()
    var Question = String()
    var Value = String()
    var TextField: UITextField?
    var CommTextView: UITextView?
    var RepTextView: UITextView?
    var Question_type = String()
    //var Question_media = UIImage()
    var Question_media_url = String()
    var Question_video_thum = UIImage(named: "")
    var QuestionVideoURL = String()
    var User_opened = Bool()
    var User_opened_status = Int()
    var Thumbnail = String()

    var Date = String()
    var User_answered = Bool()
    var User_answer_status = Bool()
    var Comments = [TriviaComment]()
    var AudioStory = Audio()

    var IsExpanded = false

    init() { }
    init(_ json: JSON) {
        Post_id = json["post_id"].intValue
        Category_id = json["category_id"].intValue
        Category_name = json["category_name"].stringValue
        Question = json["question"].stringValue
        Question_type = json["question_type"].stringValue
        User_opened = json["user_opened"].boolValue
        User_opened_status = json["user_opened_status"].intValue
        Date = "  \(json["date"].stringValue)  "
        User_answered = json["user_answered"].boolValue
        User_answer_status = json["user_answer_status"].boolValue
        
        if let trivia_comments = json["comments"].array, trivia_comments.count > 0 {
            trivia_comments.forEach { (object) in
                Comments.append(TriviaComment(object))
            }
        }
        
        if let urlString = json["question_media"].string, Question_type.lowercased() == "image" {
            Question_media_url = Core.verifyUrl(urlString) ? urlString :  Constants.baseURL.appending("/\(urlString)")
            //Core.setImage(Question_media_url, image: &Question_media)
        } else if Question_type.lowercased() == "audio" {
            QuestionVideoURL = json["question_media"].stringValue
            Question_media_url = QuestionVideoURL
            AudioStory.Id = Post_id
            AudioStory.Title = Question
            AudioStory.File = QuestionVideoURL
            if let thumString = json["thumbnail"].string {
                AudioStory.ImageUrl = thumString
            }
        } else {
            QuestionVideoURL = json["question_media"].stringValue
            Question_media_url = QuestionVideoURL
//            if let medieURL = URL(string: json["question_media"].stringValue), let videoThumnail = self.getThumbnailImage(forUrl: medieURL) {
//                Question_video_thum = videoThumnail
//            }
            //Question_media = UIImage(named: "acastro_180403_1777_youtube_0001") ?? defaultImage
        }
        if let thumString = json["thumbnail"].string {
            Thumbnail = thumString
        }
    }
    
    
}
