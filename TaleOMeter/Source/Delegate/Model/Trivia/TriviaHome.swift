//
//  TriviaHome.swift
//  TaleOMeter
//
//  Created by Durgesh on 14/03/22.
//

import SwiftyJSON

struct TriviaHome {

    var Trivia_daily = TriviaDaily()
    var Trivia_category = [TriviaCategory]()
    
    init() { }
    init(_ json: JSON) {
        if let trivia_daily = json["trivia_daily"].dictionaryObject {
            Trivia_daily = TriviaDaily(JSON(trivia_daily))
        }
        
        if let trivia_category = json["trivia_category"].array {
            trivia_category.forEach { (object) in
                Trivia_category.append(TriviaCategory(object))
            }
        }
    }
}

/*{
 "trivia_daily": {
     "title": "Daily",
     "post_count": 0
 },
 "trivia_category": [
     {
         "category_id": 10,
         "category_name": "Fantasy movies",
         "post_count": 0,
         "category_image": "https://dev-taleometer.estrradoweb.com/storage/app/public/trivia_category/0mkVz1xyroE2KUr8n1dnw5vaDVSCGLi2fa2ZEQ0r.jpg"
     },
     {
         "category_id": 8,
         "category_name": "Indian films",
         "post_count": 1,
         "category_image": "https://dev-taleometer.estrradoweb.com/storage/app/public/trivia_category/fDsQ7386BmlfcsOgYYaQaz9hKUQ1ZPNZ90Hf6Wlh.jpg"
     }
 ]
}*/
