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
    
    // MARK: - Public Property -
    var storyData = StoryModel()
    var isStroy = false
    var isPlot = false
    var isNarration = false

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //bannerImage.image = storyData.Image
        profileImage.image = storyData.Image
        favButton.isHidden = true
        titleLabel.text = storyData.Name
        storiesLabel.text = "0\nStories"
        lengthLabel.text = "0\nLength"
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
        //sender.isSelected = !sender.isSelected
    }
    
    // MARK: - Play Pause current audio -
    @objc private func playPauseAudio(_ notification: Notification) {
        if (notification.userInfo?["isPlaying"] as? Bool) != nil {
            self.playButton.isSelected = true
        } else {
            self.playButton.isSelected = true
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "audioList", let segVC = segue.destination as? AudioListViewController {
            segVC.parentConroller = self
            segVC.storyData = self.storyData
            segVC.isStroy = self.isStroy
            segVC.isPlot = self.isPlot
            segVC.isNarration = self.isNarration
        }
    }
}

// MARK: - PromptViewDelegate -
extension AuthorViewController: PromptViewDelegate {
    func didActionOnPromptButton(_ tag: Int) {
        AudioPlayManager.shared.didActionOnPromptButton(tag)
    }
}