//
//  Constants.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//  Copyright © 2022 Durgesh. All rights reserved.
//

import UIKit

struct Constants {
    
//    static let baseURL = "h   ttps://dev-taleometer.estrradoweb.com"
//    static let baseURL = "https://app.taleometer.com"
//    static let baseURL = "https://live.taleometer.com"
    static let baseURL = "https://dev-taleometer.estrradoweb.com/qa"

    // Trivia Live: com.app.taleometer
    // Trivia UAT: com.estrrado.taleometer
    // Taleometer v1: com.estrrado.v1.taleometer
    static let GOOGLE_IOS_CLIENT_ID = "1018972893351-fspd9pnm1hgpknlb3mt2j896nfb999od.apps.googleusercontent.com"
    
    static let loaderImage = UIImage.gif(name: "spinner1")
    static let loaderImageBig = UIImage.gif(name: "spinner11")
    static let appVersion = 1.04
    static let enableForceUpdate = false
    
    struct Storyboard {
        static let dashboard = "Main"
        static let sideMenu = "SideMenu"
        static let launch = "LaunchScreen"
        static let auth = "Auth"
        static let audio = "Audio"
        static let other = "Other"
        static let trivia = "Trivia"
        static let chat = "Chat"
    }
    
    struct UserDefault {
        static let AuthTokenStr = "authenticateToken"
        static let FCMTokenStr = "FCMNotificationToken"
        static let IsLogin = "isLogin"
        static let ProfileData = "ProfileData"
        static let StartUsageId = "StartUsageId"
        static let GuideCompleted = "GuideCompleted"
    }
    
    public struct DateFormate {
        static let app = "dd/MM/yyyy"
        static let appWithTime = "dd/MM/yyyy    HH:mma"
        static let server = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        static let serverDate = "yyyy-MM-dd"
        static let serverWithTime = "yyyy-MM-dd'T'HH:mm:ss"
        static let aPIWithTime = "yyyy-MM-dd HH:mm:ss"
    }
    
    public struct ActivityScreenName {
        static let triviaHome = "homepage"
        static let triviaDaily = "daily"
        static let triviaCategory = "category"
        static let triviaPost = "post"
        static let triviaComment = "comment"
        static let leaderboard = "leaderboard"
        static let notification = "notification"
        static let message = "message"
        static let faq = "FAQ"
    }
    
    public struct ActivityType {
        static let trivia = "trivia"
        static let story = "story"
    }
}
