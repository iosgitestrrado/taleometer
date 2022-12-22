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
    // Making this a weak variable, so that it won't create a strong reference cycle
    weak var delegate: AudioListViewDelegate? = nil
    
    // MARK: - Public Property -
    var storyData = StoryModel()
    var currentAudio = Audio()
    var isStroy = false
    var isPlot = false
    var isNarration = false

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //bannerImage.image = storyData.Image
        profileImage.sd_setImage(with: URL(string: storyData.ImageUrl), placeholderImage: defaultImage, options: [], context: nil)

        if isPlot || isNarration {
            bannerImage.sd_setImage(with: URL(string: storyData.CoverImageUrl), placeholderImage: defaultImage, options: [], context: nil)
        }
        bannerImage.alpha = 0.75
        favButton.isHidden = true
        titleLabel.text = storyData.Name
        storiesLabel.text = "0\nStories"
        lengthLabel.text = "0\nLength"
        
        NotificationCenter.default.addObserver(self, selector: #selector(playPauseAudio(_:)), name: remoteCommandName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playButtonSelected(_:)), name: Notification.Name(rawValue: "mainScreenPlay"), object: nil)
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
    
    @IBAction func tapOnShuffle(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        NotificationCenter.default.post(name: Notification.Name(rawValue: "shuffleAudio"), object: nil)
    }
    
    @IBAction func tapOnPlay(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        NotificationCenter.default.post(name: Notification.Name(rawValue: "playStoryAudio"), object: nil, userInfo: ["PlayNow" : sender.isSelected])
    }
    
    @objc private func playButtonSelected(_ notification: Notification) {
        if let IsSelected = notification.userInfo?["IsSelected"] as? Bool {
            self.playButton.isSelected = IsSelected
        }
        if let totalStories = notification.userInfo?["TotalStories"] as? Int {
            storiesLabel.text = "\(totalStories)\nStories"
        }
    }
    
    // MARK: - Play Pause current audio -
    @objc private func playPauseAudio(_ notification: Notification) {
        if (notification.userInfo?["isPlaying"] as? Bool) != nil {
            if let player = AudioPlayManager.shared.playerAV, player.isPlaying {
                self.playButton.isSelected = true
                return
            }
        }
        self.playButton.isSelected = false
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
            segVC.delegate = self.delegate
            segVC.currentAudio = self.currentAudio
        }
    }
}

// MARK: - PromptViewDelegate -
extension AuthorViewController: PromptViewDelegate {
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
