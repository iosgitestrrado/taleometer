//
//  Constants.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//  Copyright © 2022 Durgesh. All rights reserved.
//

import UIKit

struct Constants {
    
//    static let baseURL = "https://dev-taleometer.estrradoweb.com"
    static let baseURL = "https://app.taleometer.com"

    static let loaderImage = UIImage.gif(name: "spinner1")
    
    struct Storyboard {
        static let dashboard = "Main"
        static let sideMenu = "SideMenu"
        static let launch = "LaunchScreen"
        static let auth = "Auth"
        static let audio = "Audio"
        static let other = "Other"
        static let trivia = "Trivia"
    }
    
    struct UserDefault {
        static let AuthTokenStr = "authenticateToken"
        static let IsLogin = "isLogin"
        static let ProfileData = "ProfileData"
        static let StartUsageId = "StartUsageId"
    }
    
    public struct DateFormate {
        static let app = "dd/MM/yyyy"
        static let appWithTime = "dd/MM/yyyy HH:mm:ss"
        static let server = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        static let serverDate = "yyyy-MM-dd"
        static let serverWithTime = "yyyy-MM-dd'T'HH:mm:ss"
        static let aPIWithTime = "yyyy-MM-dd HH:mm:ss"
    }
}
