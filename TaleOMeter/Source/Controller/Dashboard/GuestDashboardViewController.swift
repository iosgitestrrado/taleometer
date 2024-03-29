//
//  GuestDashboardViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 12/02/22.
//

import UIKit
import LGSideMenuController

class GuestDashboardViewController: UIViewController {

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
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true)
        self.navigationItem.hidesBackButton = true
        
        FooterManager.addFooter(self, bottomConstraint: containerBottomCons)
        if AudioPlayManager.shared.isMiniPlayerActive {
            AudioPlayManager.shared.addMiniPlayer(self, bottomConstraint: self.containerBottomCons)
        }
    }
    
    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        self.sideMenuController!.toggleRightView(animated: true)
    }
    
    @IBAction func tapOnSurprise(_ sender: Any) {
        Core.push(self, storyboard: Constants.Storyboard.auth, storyboardId: "LoginViewController")
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segmentview", let segVC = segue.destination as? SegmentViewController {
            segVC.parentController = self
            segVC.parentFrame = self.containerView.frame
        }
    }
}

// MARK: - PromptViewDelegate -
extension GuestDashboardViewController: PromptViewDelegate {
    func didActionOnPromptButton(_ tag: Int) {
        if tag == 9 {
            if !Reachability.isConnectedToNetwork() {
                Core.noInternet(self)
                return
            }
            AuthClient.logout("Logged out successfully", moveToLogin: false)
            Core.push(self, storyboard: Constants.Storyboard.auth, storyboardId: LoginViewController().className)
            return
        }
        AudioPlayManager.shared.didActionOnPromptButton(tag)
    }
}
