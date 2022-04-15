//
//  PromptViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit

// MARK: - Protocol used for sending data back -
protocol PromptViewDelegate: AnyObject {
    func didActionOnPromptButton(_ tag: Int)
}

class PromptViewController: UIViewController {

    // MARK: - Weak Property -
    @IBOutlet weak var audioPromptView: UIView!
    @IBOutlet weak var songTitleLbl: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var audioImageView: UIImageView!
    @IBOutlet weak var remainSecondLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var favButton: UIButton!

    @IBOutlet weak var verifyPromptView: UIView!
    @IBOutlet weak var verifyImage: UIImageView!
    @IBOutlet weak var titleLabelV: UILabel!
    @IBOutlet weak var messageLabelV: UILabel!
    
    @IBOutlet weak var answerPromptView: UIView!
    @IBOutlet weak var questionImage: UIImageView!
    @IBOutlet weak var answerTitle: UILabel!
    @IBOutlet weak var answerMessage: UILabel!
    @IBOutlet weak var answerImage: UIImageView!

    // Making this a weak variable, so that it won't create a strong reference cycle
    weak var delegate: PromptViewDelegate? = nil
    
    // MARK: - Public Properties -
    var songTitle = ""
    var nextSongTitle = ""
    var isAudioPrompt: Bool = false
    var isCloseBtnHide: Bool = false
    var currentController = UIViewController()
    var isFromFavourite: Bool = false

    // MARK: - Private Properties -
    private var timer = Timer()
    private var remainingSecond = 5
    
    private var font16 = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0) ]
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        closeButton.isHidden = isCloseBtnHide
        self.favButton.isSelected = AudioPlayManager.shared.currentAudio.Is_favorite
        if isAudioPrompt {
            //You Just listened to "Track To Relax"
            let titleString = NSMutableAttributedString(string: "You Just listened to \n\"\(songTitle)\"")
            
            
            var font22 = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22.0) ]
            
            if let regular16 = UIFont(name: "CommutersSans-Regular", size: 16.0) {
                font16 = [ NSAttributedString.Key.font: regular16 ]
            }
            
            if let regular22 = UIFont(name: "CommutersSans-Regular", size: 22.0) {
                font22 = [ NSAttributedString.Key.font: regular22 ]
            }
            
            let rangeTitle1 = NSRange(location: 0, length: 21)
            let rangeTitle2 = NSRange(location: 21, length: songTitle.utf8.count + 2) // 10 is title character length
            
            titleString.addAttributes(font16, range: rangeTitle1)
            titleString.addAttributes(font22, range: rangeTitle2)
            self.songTitleLbl.attributedText = titleString
            
            setRemainTitle()
            
            timer = Timer(timeInterval: 1.0, target: self, selector: #selector(PromptViewController.updateTimer), userInfo: nil, repeats: true)
            RunLoop.main.add(self.timer, forMode: .default)
            timer.fire()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setRemainTitle() {
        //Learn Brightly Up Next In 5s
        let remainString = NSMutableAttributedString(string: "\(nextSongTitle) \n Up Next In \n \(remainingSecond)s")

        var font48 = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 48.0) ]
        
        if let regular16 = UIFont(name: "CommutersSans-Regular", size: 16.0) {
            font16 = [ NSAttributedString.Key.font: regular16 ]
        }
        
        if let regular48 = UIFont(name: "CommutersSans-Regular", size: 48.0) {
            font48 = [ NSAttributedString.Key.font: regular48 ]
        }
        
        let rangeRemain1 = NSRange(location: 0, length: nextSongTitle.utf8.count + 14)// 10 is title character length
        let rangeRemain2 = NSRange(location: remainString.length - 2, length: 2) // 9 is total of title character length + 10
        
        remainString.addAttributes(font16, range: rangeRemain1)
        remainString.addAttributes(font48, range: rangeRemain2)
        self.remainSecondLabel.attributedText = remainString
    }
    
    @objc func updateTimer() {
        if remainingSecond < 0 {
            timer.invalidate()
            self.delegate?.didActionOnPromptButton(2)
            self.dismiss(animated: true, completion: nil)
        } else {
            setRemainTitle()
        }
        remainingSecond -= 1
    }
    
    // 0 - tag
    @IBAction func tapOnAddToFav(_ sender: UIButton) {
        if sender.isSelected {
            self.favButton.isSelected = false
            self.removeFromFav()
        } else {
            self.addToFav()
        }
        //self.delegate?.didActionOnPromptButton(0)
    }
    
    // 0 - Once more, 1 - Share (Delegate - 1 To once more, 4 to share)
    @IBAction func tapOnOnceMore(_ sender: UIButton) {
        if sender.tag == 0 {
            timer.invalidate()
            self.delegate?.didActionOnPromptButton(1)
            self.dismiss(animated: true, completion: nil)
        } else if sender.tag == 1 {
            timer.invalidate()
            AudioPlayManager.shareAudio(self) { [self] status in
                timer = Timer(timeInterval: 1.0, target: self, selector: #selector(PromptViewController.updateTimer), userInfo: nil, repeats: true)
                RunLoop.main.add(self.timer, forMode: .default)
                timer.fire()
            }
        }
    }
    
    // 2 - tag
    @IBAction func tapOnConfirm(_ sender: Any) {
        if timer.isValid {
            timer.invalidate()
        }
        if let delegate = delegate {
            delegate.didActionOnPromptButton(2)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapOnClose(_ sender: Any) {
        if timer.isValid {
            timer.invalidate()
        }
        if let delegate = delegate {
            delegate.didActionOnPromptButton(3)
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension PromptViewController {
    // Add to favourite
    private func addToFav() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        DispatchQueue.global(qos: .background).async {
            FavouriteAudioClient.add(FavouriteRequest(audio_story_id: AudioPlayManager.shared.currentAudio.Id)) { [self] status in
                if let st = status, st {
                    if isFromFavourite {
                        NotificationCenter.default.post(name: NSNotification.Name("ChangeFavAudio"), object: nil, userInfo: ["isAdded" : true])
                    }
                    AudioPlayManager.shared.currentAudio.Is_favorite = true
                    self.favButton.isSelected = true
                    if AudioPlayManager.shared.audioList != nil {
                        AudioPlayManager.shared.audioList![AudioPlayManager.shared.currentIndex].Is_favorite = true
                    }
                }
            }
        }
    }
    
    // Remove from favourite
    private func removeFromFav() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        DispatchQueue.global(qos: .background).async {
            FavouriteAudioClient.remove(FavouriteRequest(audio_story_id: AudioPlayManager.shared.currentAudio.Id)) { [self] status in
                if let st = status, st {
                    if isFromFavourite {
                        NotificationCenter.default.post(name: NSNotification.Name("ChangeFavAudio"), object: nil, userInfo: ["isRemoved" : true])
                    }
                    AudioPlayManager.shared.currentAudio.Is_favorite = false
                    self.favButton.isSelected = false
                    if AudioPlayManager.shared.audioList != nil {
                        AudioPlayManager.shared.audioList![AudioPlayManager.shared.currentIndex].Is_favorite = false
                    }
                } else {
                    self.favButton.isSelected = true
                }
            }
        }
    }
}
