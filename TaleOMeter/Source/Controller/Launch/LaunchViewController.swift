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
//        Core.push(self, storyboard: Constants.Storyboard.trivia, storyboardId: "TRFeedViewController")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let profileData = Login.getProfileData(), profileData.Is_login, !profileData.StoryBoardName.isBlank, !profileData.StoryBoardId.isBlank {
                Core.push(self, storyboard: profileData.StoryBoardName, storyboardId: profileData.StoryBoardId)
            } else {
                Core.push(self, storyboard: Constants.Storyboard.dashboard, storyboardId: "DashboardViewController")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // Core.showNavigationBar(cont: self, setNavigationBarHidden: true, isRightViewEnabled: false)
    }
}
