//
//  SceneDelegate.swift
//  TaleOMeter
//
//  Created by Durgesh on 12/02/22.
//

import UIKit
import AVFoundation
import FacebookCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        Login.setGusetData()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print(error.localizedDescription)
        }
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        UserDefaults.standard.set(true, forKey: Constants.UserDefault.GuideCompleted)

        let sideMenuStoryboard = UIStoryboard(name: Constants.Storyboard.sideMenu, bundle: nil)
        let launchStoryboard = UIStoryboard(name: Constants.Storyboard.launch, bundle: nil)
        let navigationController = sideMenuStoryboard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
        navigationController.setViewControllers([launchStoryboard.instantiateViewController(withIdentifier: "LaunchViewController")], animated: false)

        let mainViewController = sideMenuStoryboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        mainViewController.rootViewController = navigationController
        
        window.rootViewController = mainViewController
        UIView.transition(with: window, duration: 0.3, options: [.transitionCrossDissolve], animations: nil, completion: nil)
        self.window = window
        window.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        if UserDefaults.standard.bool(forKey: Constants.UserDefault.IsLogin) && !AudioPlayManager.shared.isAudioPlaying {
            let startUsageId = UserDefaults.standard.integer(forKey: Constants.UserDefault.StartUsageId)
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = Constants.DateFormate.aPIWithTime
            OtherClient.endUsage(EndUsageRequest(usage_id: startUsageId, time: dateFormat.string(from: Date()))) { status in }
        }
        print("Kill App")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        print("Going to background")
        if UserDefaults.standard.bool(forKey: Constants.UserDefault.IsLogin) && !AudioPlayManager.shared.isAudioPlaying {
            let startUsageId = UserDefaults.standard.integer(forKey: Constants.UserDefault.StartUsageId)
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = Constants.DateFormate.aPIWithTime
            DispatchQueue.global(qos: .background).async {
                OtherClient.endUsage(EndUsageRequest(usage_id: startUsageId, time: dateFormat.string(from: Date()))) { status in }
            }
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print("Activing from background")
        if UserDefaults.standard.bool(forKey: Constants.UserDefault.IsLogin) && !AudioPlayManager.shared.isAudioPlaying {
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = Constants.DateFormate.aPIWithTime
            DispatchQueue.global(qos: .background).async {
                OtherClient.startUsage(StartUsageRequest(time: dateFormat.string(from: Date()))) { response in
                    if let data = response {
                        UserDefaults.standard.set(data.Id, forKey: Constants.UserDefault.StartUsageId)
                    }
                }
            }
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}

