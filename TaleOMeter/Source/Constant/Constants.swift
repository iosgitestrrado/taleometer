//
//  Constants.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//  Copyright © 2022 Durgesh. All rights reserved.
//

struct Constants {
    
    static let baseURL = "https://dev-taleometer.estrradoweb.com/api"
    
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
    }
}
