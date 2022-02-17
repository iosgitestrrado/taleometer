//
//  AudioPlayManager.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit
import AVFoundation

class AudioPlayManager: NSObject {
    // MARK: - Create shared instance for reference and static-
    static let shared = AudioPlayManager()
    static let playImageName = "play"
    static let pauseImageName = "pause"
    
    // MARK: - Variable -
    var currController = UIViewController()
    var audioContainer = AudioContainerViewController()
    
    var isPlaying: Bool = false
    var isPause: Bool = false
    var isContainerAdded: Bool = false
    
    var songIndex = 0
    var nextSongIndex = 0
    var prevSongIndex = 0
    var playerAV: AVPlayer = AVPlayer()
    
    func configAudio(_ url: URL) {
        do {
            try
            AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            let playerItem = AVPlayerItem(url: url)
            playerAV = AVPlayer.init(playerItem: playerItem)
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
        
    func play(_ songIndexs: Int, control: UIViewController) {
        songIndex = songIndexs
        nextSongIndex = songIndexs + 1
        prevSongIndex = songIndexs - 1
        if nextSongIndex > 2 {
            nextSongIndex = 0
        }
        if prevSongIndex < 0 {
            prevSongIndex = 0
        }
        
        guard let streamURL = Bundle.main.url(forResource: "file_example_MP3_5MG", withExtension: "mp3") else { return }
        let playerItem = AVPlayerItem(url: streamURL)
        playerAV = AVPlayer.init(playerItem: playerItem)
        do {
            try
            AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        //        playerAV = AVPlayer.init(url: streamURL)
        playerAV.play()
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        isPlaying = true
        isPause = false
        
        if (control.view.viewWithTag(99999995) == nil) {
            self.addAudioConatainer(control)
        } else {
            audioContainer.songTitle.text = "File Example MP3 5MG"
            if isPlaying {
                audioContainer.playButton.setBackgroundImage(#imageLiteral(resourceName: AudioPlayManager.pauseImageName), for: .normal)
            } else {
                audioContainer.playButton.setBackgroundImage(#imageLiteral(resourceName: AudioPlayManager.playImageName), for: .normal)
            }
        }
    }
    
    func addAudioConatainer(_ controller: UIViewController) {
        currController.view.viewWithTag(99999995)?.removeFromSuperview()
        audioContainer.view.removeFromSuperview()
        audioContainer = UIStoryboard.init(name: Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "AudioContainerViewController") as! AudioContainerViewController
        audioContainer.view.frame = CGRect.init(x: 0, y: UIScreen.main.bounds.size.height - (60.0 * UIScreen.main.bounds.size.height / 667.0), width: UIScreen.main.bounds.size.width, height: 60.0 * UIScreen.main.bounds.size.height / 667.0)
       
        audioContainer.songTitle.text = "File Example MP3 5MG"
        
        if isPlaying {
            audioContainer.playButton.setBackgroundImage(#imageLiteral(resourceName: AudioPlayManager.pauseImageName), for: .normal)
        } else {
            audioContainer.playButton.setBackgroundImage(#imageLiteral(resourceName: AudioPlayManager.playImageName), for: .normal)
        }
        audioContainer.playButton.addTarget(self, action: #selector(tapOnPlayBottom(_:)), for: .touchUpInside)
        audioContainer.fullViewButton.addTarget(self, action: #selector(tapOnContainer(_:)), for: .touchUpInside)
        
        audioContainer.view.tag = 99999995
        isContainerAdded = true
        controller.view.addSubview(audioContainer.view)
        currController = controller
    }
    
    @objc func itemDidFinishPlaying(notification: NSNotification) {
        self.play(nextSongIndex, control: currController)
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FinishedPlayingFav"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FinishedPlaying"), object: nil)
    }
    
    @objc func tapOnPlayBottom(_ sender: UIButton) {
        if isPlaying {
            isPlaying = false
            isPause = true
            playerAV.pause()
            sender.setBackgroundImage(#imageLiteral(resourceName: AudioPlayManager.playImageName), for: .normal)
        } else if isPause {
            isPause = false
            isPlaying = true
            playerAV.play()
            sender.setBackgroundImage(#imageLiteral(resourceName: AudioPlayManager.pauseImageName), for: .normal)
        }
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FinishedPlayingFav"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FinishedPlaying"), object: nil)
    }
    
    @objc func tapOnNextButton() {
        self.play(nextSongIndex, control: currController)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FinishedPlaying"), object: nil)
    }
    
    @objc func tapOnPrevButton() {
        self.play(prevSongIndex, control: currController)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FinishedPlaying"), object: nil)
    }
    
    @objc func tapOnContainer(_ sender: UIButton) {
        let nowPlayView = UIStoryboard.init(name: Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "NowPlayViewController") as! NowPlayViewController
        currController.navigationController?.present(nowPlayView, animated: true, completion: nil)
    }
}


// MARK: Check audio is playing
extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
