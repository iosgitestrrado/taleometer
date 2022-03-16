//
//  LaunchViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 12/02/22.
//

import UIKit
import SwiftGifOrigin

class LaunchViewController: UIViewController {
    
    // MARK: - Weak Properties -
    @IBOutlet weak var splashImage: UIImageView!
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.splashImage.image = UIImage.gif(name: "splash_anim_new")
        
        if isOnlyTrivia {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let profileData = Login.getProfileData() {
                    if profileData.Is_login, !profileData.StoryBoardName.isBlank, !profileData.StoryBoardId.isBlank {
                       Core.push(self, storyboard: profileData.StoryBoardName, storyboardId: profileData.StoryBoardId)
                    } else if profileData.Is_login {
                        Core.push(self, storyboard: Constants.Storyboard.trivia, storyboardId: "TriviaViewController")
                    } else {
                        Core.push(self, storyboard: Constants.Storyboard.auth, storyboardId: "LoginViewController")
                    }
                } else {
                    Core.push(self, storyboard: Constants.Storyboard.auth, storyboardId: "LoginViewController")
                }
            }
        } else {
            if let profileData = Login.getProfileData() {
                if profileData.Is_login, !profileData.StoryBoardName.isBlank, !profileData.StoryBoardId.isBlank {
                    Core.push(self, storyboard: profileData.StoryBoardName, storyboardId: profileData.StoryBoardId)
                } else if profileData.Is_login {
                    getFavAudio()
                } else {
                    Core.push(self, storyboard: Constants.Storyboard.dashboard, storyboardId: "DashboardViewController")
                }
            } else {
                Core.push(self, storyboard: Constants.Storyboard.dashboard, storyboardId: "DashboardViewController")
            }
        }
    }
    
    private func getFavAudio() {
        if Reachability.isConnectedToNetwork() {
            DispatchQueue.global(qos: .background).async {
                FavouriteAudioClient.get("all") { response in
                    if let fav = response {
                        favouriteAudio = fav
                    }
                    Core.push(self, storyboard: Constants.Storyboard.dashboard, storyboardId: "DashboardViewController")
                }
            }
        } else {
            Core.push(self, storyboard: Constants.Storyboard.dashboard, storyboardId: "DashboardViewController")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // Core.showNavigationBar(cont: self, setNavigationBarHidden: true, isRightViewEnabled: false)
    }
}
