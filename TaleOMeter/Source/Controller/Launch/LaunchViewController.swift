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
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if isOnlyTrivia {
                if let profileData = Login.getProfileData() {
                    if profileData.Is_login, !profileData.StoryBoardName.isBlank, !profileData.StoryBoardId.isBlank {
                        Core.push(self, storyboard: profileData.StoryBoardName, storyboardId: profileData.StoryBoardId)
                    } else if profileData.Is_login {
                        if categorId != -2 {
                            if let myobject = UIStoryboard(name: Constants.Storyboard.trivia, bundle: nil).instantiateViewController(withIdentifier: "TRFeedViewController") as? TRFeedViewController {
                                myobject.categoryId = categorId
                                myobject.redirectToPostId = postId
                                self.navigationController?.pushViewController(myobject, animated: true)
                                return
                            }
                        }
                        Core.push(self, storyboard: Constants.Storyboard.trivia, storyboardId: "TriviaViewController", animated: false)
                    } else {
                        Core.push(self, storyboard: Constants.Storyboard.auth, storyboardId: "LoginViewController", animated: false)
                    }
                } else {
                    Core.push(self, storyboard: Constants.Storyboard.auth, storyboardId: "LoginViewController", animated: false)
                }
            } else {
                if let profileData = Login.getProfileData() {
                    if profileData.Is_login, !profileData.StoryBoardName.isBlank, !profileData.StoryBoardId.isBlank {
                        Core.push(self, storyboard: profileData.StoryBoardName, storyboardId: profileData.StoryBoardId, animated: false)
                        return
                    }
                }
                if UserDefaults.standard.bool(forKey: Constants.UserDefault.IsLogin) && storyId != -1 {
                    if let myobject = UIStoryboard(name: Constants.Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "NowPlayViewController") as? NowPlayViewController {
                        myobject.storyIdis = storyId
                        self.navigationController?.pushViewController(myobject, animated: true)
                        return
                    }
                }
                Core.push(self, storyboard: Constants.Storyboard.dashboard, storyboardId: "DashboardViewController", animated: false)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // Core.showNavigationBar(cont: self, setNavigationBarHidden: true, isRightViewEnabled: false)
    }
}
