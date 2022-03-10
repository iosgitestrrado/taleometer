//
//  DashboardViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 12/02/22.
//

import UIKit
import LGSideMenuController

class DashboardViewController: UIViewController {

    // MARK: - Weak Property -
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerBottomCons: NSLayoutConstraint!
    @IBOutlet weak var surpriseButton: UIButton!
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.surpriseButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true, titleInLeft: false)
        self.navigationItem.hidesBackButton = true
        
        //Add footer view and manager current view frame
        FooterManager.addFooter(self, bottomConstraint: self.containerBottomCons)
        if AudioPlayManager.shared.isMiniPlayerActive {
            AudioPlayManager.shared.addMiniPlayer(self, bottomConstraint: self.containerBottomCons)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        self.sideMenuController!.toggleRightView(animated: true)
    }
    
    @IBAction func tapOnNonStop(_ sender: UIButton) {
        if UserDefaults.standard.bool(forKey: Constants.UserDefault.IsLogin) {
            UIView.transition(with: sender as UIView, duration: 0.75, options: .transitionCrossDissolve) {
                sender.isSelected = !sender.isSelected
            } completion: { [self] isDone in
                if sender.isSelected {
                    Core.push(self, storyboard: Constants.Storyboard.audio, storyboardId: "NonStopViewController")
                } else {
                    AudioPlayManager.shared.isNonStop = !sender.isSelected
                    AudioPlayManager.shared.isMiniPlayerActive = !sender.isSelected
                    AudioPlayManager.shared.removeMiniPlayer()
                }
            }
        } else {
            Core.push(self, storyboard: Constants.Storyboard.auth, storyboardId: "LoginViewController")
        }
    }
    
    @IBAction func tapOnSurprise(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.UserDefault.IsLogin) {
            Core.push(self, storyboard: Constants.Storyboard.audio, storyboardId: "NowPlayViewController")
        } else {
            Core.push(self, storyboard: Constants.Storyboard.auth, storyboardId: "LoginViewController")
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segmentview", let segVC = segue.destination as? SegmentViewController {
            segVC.parentController = self
            self.containerView.frame.size.width = CGFloat((335.0 * UIScreen.main.bounds.width) / 375.0)
            segVC.parentFrame = self.containerView.frame
        }
    }
}
