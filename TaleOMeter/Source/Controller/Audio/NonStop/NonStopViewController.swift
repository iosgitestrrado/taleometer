//
//  NonStopViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit
import CoreMedia
import AVFoundation

class NonStopViewController: UIViewController {

    // MARK: - Weak Property -
    @IBOutlet weak var audioImage: UIImageView!
    @IBOutlet weak var audioTitle: UILabel!
    @IBOutlet weak var audioTime: UILabel!
    @IBOutlet weak var storyLabel: UIButton!
    @IBOutlet weak var plotLabel: UIButton!
    @IBOutlet weak var narrotionLabel: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var favButton: UIButton!
    
    // MARK: - Public Properties -
    public var existingAudio = false

    // MARK: - Private Properties -
    private var totalTimeDuration: Float = 0.0
    private var audioTimer = Timer()
    private var isPlaying = false
    private var player = AVPlayer()
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.audioImage.cornerRadius = self.audioImage.frame.size.height / 2.0
        configureAudio()
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishedPlaying), name: NSNotification.Name(rawValue: "FinishedPlaying"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.audioImage.cornerRadius = self.audioImage.frame.size.height / 2.0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        audioTimer.invalidate()
    }
    
    // MARK: - SPN stands Story(0) Plot(1) and Narrotion(2)
    @IBAction func tapOnSPNButton(_ sender: UIButton) {
        Core.push(self, storyboard: Storyboard.audio, storyboardId: "AuthorViewController")
        switch sender.tag {
        case 0:
            //Story
            break
        case 1:
            //Plot
            break
        default:
            //Narrotion
            break
        }
    }
    
    // MARK: - Play(0) Next(1) Favourite(2)
    @IBAction func tapOnAudioController(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            //Play
            self.playPauseAudio(!player.isPlaying)
            break
        case 1:
            //Next
            itemDidFinishedPlaying()
            break
        default:
            //Favourite
            sender.isSelected = !sender.isSelected
            break
        }
    }

    // MARK: Set audio wave meter
    private func configureAudio(_ isNext: Bool = false) {
        AudioPlayManager.shared.isNonStop = true
        //guard let url = Bundle.main.url(forResource: "file_example_MP3_5MG", withExtension: "mp3") else { return }
        guard let url = Bundle.main.path(forResource: "testAudio", ofType: "mp3") else { return }
        
        if existingAudio, let playerk = AudioPlayManager.shared.playerAV {
            player = playerk
            AudioPlayManager.shared.isMiniPlayerActive = true
            DispatchQueue.main.async {
                self.udpateTime()
            }
            if let duration = player.currentItem?.asset.duration {
                totalTimeDuration = Float(CMTimeGetSeconds(duration))
            }
            
            self.playButton.isSelected = player.isPlaying
            if player.isPlaying {
                audioTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(NowPlayViewController.udpateTime), userInfo: nil, repeats: true)
                RunLoop.main.add(self.audioTimer, forMode: .default)
                audioTimer.fire()
            }
        } else {
            AudioPlayManager.shared.configAudio(URL(fileURLWithPath: url))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                self.playButton.isSelected = false
                if let duration = player.currentItem?.asset.duration {
                    totalTimeDuration = Float(CMTimeGetSeconds(duration))
                }
                if let playerk = AudioPlayManager.shared.playerAV {
                    self.player = playerk
                    if isNext && isPlaying {
                        if audioTimer.isValid {
                            audioTimer.invalidate()
                        }
                        playPauseAudio(true)
                    } else {
                        self.udpateTime()
                    }
                }
            }
        }
    }
    
    private func playPauseAudio(_ playing: Bool) {
        self.playButton.isSelected = playing
        isPlaying = playing
        if !playing {
            player.pause()
            audioTimer.invalidate()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "pauseAudio"), object: nil)
        } else {
            player.play()
            audioTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(NonStopViewController.udpateTime), userInfo: nil, repeats: true)
            RunLoop.main.add(self.audioTimer, forMode: .default)
            audioTimer.fire()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "playAudio"), object: nil)
        }
    }
    
    @objc private func itemDidFinishedPlaying() {
        existingAudio = false
        configureAudio(true)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "nextAudio"), object: nil)
    }
    
    @objc func udpateTime() {
        if let currentItem = player.currentItem {
            // Get the current time in seconds
            let playhead = currentItem.currentTime().seconds
            let duration = currentItem.duration.seconds - currentItem.currentTime().seconds
            // Format seconds for human readable string
            if !playhead.isNaN && !duration.isNaN {
                if playhead > 0 {
                    self.audioTime.text = "\(AudioPlayManager.formatTimeFor(seconds: playhead + 1)) \\ \(AudioPlayManager.formatTimeFor(seconds: duration))"
                } else {
                    self.audioTime.text = "\(AudioPlayManager.formatTimeFor(seconds: playhead)) \\ \(AudioPlayManager.formatTimeFor(seconds: duration))"
                }
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "nonstop", let audVC = segue.destination as? AudioListViewController {
            audVC.isNonStop = true
        }
    }

}
