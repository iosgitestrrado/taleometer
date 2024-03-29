//
//  FavouriteViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit

class FavouriteViewController: UIViewController {

    // MARK: - Weak Property -
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerBottomCons: NSLayoutConstraint!
    
    // MARK: - Public Property -
    
    // MARK: - Private Property -
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true)
        
        //Add footer view and manager current view frame
//        FooterManager.addFooter(self, bottomConstraint: self.containerBottomCons, isFavorite: true)
        if AudioPlayManager.shared.isMiniPlayerActive {
            AudioPlayManager.shared.addMiniPlayer(self, bottomConstraint: self.containerBottomCons)
        }
    }
    
    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        self.sideMenuController!.toggleRightView(animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "audioList", let audListVC = segue.destination as? AudioListViewController {
            audListVC.isFavourite = true
            audListVC.parentConroller = self
            audListVC.containerBottomCons = self.containerBottomCons
        }
    }
}

// MARK: - PromptViewDelegate -
extension FavouriteViewController: PromptViewDelegate {
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
