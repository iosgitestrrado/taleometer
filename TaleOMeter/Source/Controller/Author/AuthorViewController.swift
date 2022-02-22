//
//  AuthorViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit

class AuthorViewController: UIViewController {

    // MARK: - Weak Property -
    @IBOutlet weak var containerBottomCons: NSLayoutConstraint!
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var storiesLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true)
        
        //Add footer view and manager current view frame
        FooterManager.addFooter(self, bottomConstraint: self.containerBottomCons)
        if AudioPlayManager.shared.isMiniPlayerActive {
            AudioPlayManager.shared.addMiniPlayer(self, bottomConstraint: self.containerBottomCons)
        }
    }
    
    @IBAction func tapOnProfileFav(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.setBackgroundImage(UIImage(named: "active-fav"), for: .normal)
        } else {
            sender.setBackgroundImage(UIImage(named: "inactive-fav"), for: .normal)
        }
    }
    
    @IBAction func tapOnShuffle(_ sender: Any) {
    }
    
    @IBAction func tapOnPlay(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.setBackgroundImage(AudioPlayManager.pauseImage, for: .normal)
        } else {
            sender.setBackgroundImage(AudioPlayManager.playImage, for: .normal)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
//        if segue.identifier == "audioList", let segVC = segue.destination as? AudioListViewController {
//            segVC.parentController = self
//            segVC.parentFrame = self.containerView.frame
//        }
    }
}
