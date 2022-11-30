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

struct TriviaHomeRequest: Encodable {
    var model = Core.GetDeviceModel()
    var osversion = Core.GetDeviceOSVersion()
    var appversion = Core.GetAppVersion()
    var os = Core.GetDeviceOS()
    var uuid = Core.GetDeviceId()
    var manufacturer = "Apple"
    var device_name = "ios"
}

struct LeaderboardData {
    var CurrentUser = LeaderUserModel()
    var TopTen = [LeaderboardModel]()
    
    init() {  }
    init(_ json: JSON) {
        if let currentUsr = json["current_user"].dictionary {
            CurrentUser = LeaderUserModel(JSON(currentUsr))
        }
        if let topTens = json["top_ten"].array, topTens.count > 0 {
            topTens.forEach { object in
                TopTen.append(LeaderboardModel(object))
            }
        }
    }
}

struct LeaderUserModel {
    var TotalUsers = Int()
    var Rank = String()
    var Avatar = String()
    var Points = Int()
    var Name = String()
    
    init() {   }
    init(_ json: JSON) {
        TotalUsers = json["total_users"].intValue
        Rank = json["rank"].stringValue
        if let urlString = json["avatar"].string {
            Avatar = Core.verifyUrl(urlString) ? urlString : Constants.baseURL.appending("/\(urlString)")
        }
        Points = json["points"].intValue
        Name = json["name"].stringValue
    }
}

struct LeaderboardModel {

    var Avatar = String()
    var Name = String()
    var Points = String()
    var Rank = Int()

    init() { }
    init(_ json: JSON) {
        Name = json["name"].stringValue
        Points = json["points"].stringValue
        Rank = json["rank"].intValue
        if let urlString = json["avatar"].string {
            Avatar = Core.verifyUrl(urlString) ? urlString : Constants.baseURL.appending("/\(urlString)")
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
