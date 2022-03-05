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
//        Core.push(self, storyboard: Storyboard.trivia, storyboardId: "TRFeedViewController")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if UserDefaults.standard.bool(forKey: "isLogin") && !UserDefaults.standard.bool(forKey: "isRegistered"), let stName = UserDefaults.standard.string(forKey: "storyboardName"), let stId = UserDefaults.standard.string(forKey: "storyboardId") {
                Core.push(self, storyboard: stName, storyboardId: stId)
            } else {
                Core.push(self, storyboard: Storyboard.dashboard, storyboardId: "DashboardViewController")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // Core.showNavigationBar(cont: self, setNavigationBarHidden: true, isRightViewEnabled: false)
    }
}
