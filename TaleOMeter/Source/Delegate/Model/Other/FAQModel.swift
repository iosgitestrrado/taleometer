//
//  FAQModel.swift
//  TaleOMeter
//
//  Created by Durgesh on 02/12/22.
//

import SwiftyJSON

struct FAQModel {
    
    var Id = Int()
    var Question_eng = String()
    var Question_tamil = String()
    var Answer_eng = String()
    var Answer_tamil = String()
    var Answer_audio = String()
    var Is_active = Bool()
    var Is_deleted = Bool()
    var Created_at = String()
    var Updated_at = String()
    var Created_by = String()
    var Updated_by = String()
    
    init() {    }
    init(_ json: JSON) {
        Id = json["id"].intValue
        Question_eng = json["question_eng"].stringValue
        Question_tamil = json["question_tamil"].stringValue
        Answer_eng = json["answer_eng"].stringValue
        Answer_tamil = json["answer_tamil"].stringValue
        Answer_audio = json["answer_audio"].stringValue
        if let isAct = json["is_active"].int, isAct == 1 {
            Is_active = true
        }
        if let isDel = json["is_deleted"].int, isDel == 1 {
            Is_deleted = true
        }
        Created_at = json["created_at"].stringValue
        Updated_at = json["updated_at"].stringValue
        Created_by = json["created_by"].stringValue
        Updated_by = json["updated_by"].stringValue
    }
}
