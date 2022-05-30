//
//  AppDelegate.swift
//  TaleOMeter
//
//  Created by Durgesh on 12/02/22.
//

import UIKit
import Firebase

var storyId = -1
var categorId = -2//9
var postId = -1//81
var commentId = -1

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
//            self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
          }
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    internal func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        // Print notification payload data
        print("Push notification received: \(data)")
        
        let aps = data[AnyHashable("aps")]!
        
        print(aps)
    }
}


extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        UserDefaults.standard.set(fcmToken ?? "", forKey: Constants.UserDefault.FCMTokenStr)
    }
    
//    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
//        print(remoteMessage.appData)
//    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        if let storyIdn = userInfo["gcm.notification.audio_story_id"] as? String {
            storyId = Int(storyIdn) ?? -1
        }
        if let postIdn = userInfo["gcm.notification.post_id"] as? String {
            postId = Int(postIdn) ?? -1
        }
        if userInfo["gcm.notification.category_id"] is String {
            categorId = -1//Int(categoryn) ?? -2
        }
        if let commId = userInfo["gcm.notification.comment_id"] as? String {
            commentId = Int(commId) ?? -1
        }
        self.redirectedToNotification()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
//      if let messageID = userInfo[gcmMessageIDKey] {
//        print("Message ID: \(messageID)")
//      }

      // Print full message.
        print("Here: \(userInfo)")
        if let storyIdn = userInfo["gcm.notification.audio_story_id"] as? String {
            storyId = Int(storyIdn) ?? -1
        }
        if let postIdn = userInfo["gcm.notification.post_id"] as? String {
            postId = Int(postIdn) ?? -1
        }
        if userInfo["gcm.notification.category_id"] is String {
            categorId = -1//Int(categoryn) ?? -2
        }
        if let commId = userInfo["gcm.notification.comment_id"] as? String {
            commentId = Int(commId) ?? -1
        }
        if let aps = userInfo["aps"] as? [AnyHashable : AnyObject], let alert = aps["alert"] as? [AnyHashable: AnyObject], let title = alert["title"] as? String {
            Toast.show(title)
        }
        self.redirectedToNotification()
//print(Int(userInfo["gcm.notification.audio_story_id"] as! String)!)
      completionHandler(UIBackgroundFetchResult.newData)
    }
    
    private func redirectedToNotification() {
        if storyId != -1 && !isOnlyTrivia {
            if let cont = UIApplication.shared.windows.first?.rootViewController?.sideMenuController?.rootViewController as? UINavigationController {
                if (cont.children.last is NowPlayViewController) {
                    if let audioListNow = AudioPlayManager.shared.audioList, let audioIndex = audioListNow.firstIndex(where: { $0.Id == storyId }) {
                        AudioPlayManager.shared.setAudioIndex(audioIndex, isNext: false)
                        NotificationCenter.default.post(name: remoteCommandName, object: nil, userInfo: ["NotificationStoryId": storyId, "PlayCurrent": true])
                    } else {
                        NotificationCenter.default.post(name: remoteCommandName, object: nil, userInfo: ["NotificationStoryId": storyId, "PlayCurrent": false])
                    }
                } else {
                    if let myobject = UIStoryboard(name: Constants.Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "NowPlayViewController") as? NowPlayViewController {
                        if AudioPlayManager.shared.isNonStop {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "closeMiniPlayer"), object: nil)
                        }
                        if let audioListNow = AudioPlayManager.shared.audioList, let audioIndex = audioListNow.firstIndex(where: { $0.Id == storyId }) {
                            AudioPlayManager.shared.setAudioIndex(audioIndex, isNext: false)
                        }
                        myobject.storyIdis = storyId
                        cont.children.last?.navigationController?.pushViewController(myobject, animated: true)
                    }
                }
                storyId = -2
            }
        } else if categorId != -2 {
            if let cont = UIApplication.shared.windows.first?.rootViewController?.sideMenuController?.rootViewController as? UINavigationController {
                if (cont.children.last is TRFeedViewController) {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "tapOnNotification"), object: nil, userInfo: ["NotificationCategoryId": categorId, "NotificationPostId": postId, "NotificationCommentId": commentId])
                } else {
                    if let myobject = UIStoryboard(name: Constants.Storyboard.trivia, bundle: nil).instantiateViewController(withIdentifier: "TRFeedViewController") as? TRFeedViewController {
                        myobject.categoryId = categorId
                        myobject.redirectToPostId = postId
                        myobject.redirectToCommId = commentId
                        cont.children.last?.navigationController?.pushViewController(myobject, animated: true)
                    }
                }
            }
        }
    }
}
	
