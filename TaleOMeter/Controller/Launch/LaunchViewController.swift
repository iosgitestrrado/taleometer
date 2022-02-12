//
//  LaunchViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 12/02/22.
//

import UIKit
import SwiftGifOrigin

class LaunchViewController: UIViewController {
    @IBOutlet weak var splashImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.splashImage.image = UIImage.gif(name: "splash_anim_new")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let myobject = UIStoryboard(name: Storyboard.dashboard, bundle: nil).instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
            (self.sideMenuController?.rootViewController as! UINavigationController).pushViewController(myobject, animated: true)
        }
    }
}
