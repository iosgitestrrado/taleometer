//
//  NonStopViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit
import CoreMedia
import AVFoundation
import MediaPlayer
import SoundWave

class NonStopViewController: UIViewController {

    // MARK: - Weak Property -
    @IBOutlet weak var audioTitle: UILabel!
    @IBOutlet weak var audioTime: UILabel!
    @IBOutlet weak var storyLabel: UIButton!
    @IBOutlet weak var plotLabel: UIButton!
    @IBOutlet weak var narrotionLabel: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var visualizationWave: AudioVisualizationView!
    
    // MARK: - Public Properties -
    var existingAudio = false
    var waveFormcount = 0

    // MARK: - Private Properties -
    private var totalTimeDuration: Float = 0.0
    private var audioTimer = Timer()
    private var isPlaying = false
    private var player = AVPlayer()
    private var isPlayingTap = false
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureAudio()
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishedPlaying), name: NSNotification.Name(rawValue: "FinishedPlaying"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(remoteCommandHandler(_:)), name: remoteCommandName, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true, titleInLeft: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        audioTimer.invalidate()
    }
    
    //MARK: - Call funcation when audio controller press in background
    @objc private func remoteCommandHandler(_ notification: Notification) {
        if let isPlay = notification.userInfo?["isPlaying"] as? Bool {
            self.playPauseAudio(isPlay)
        }
    }
    
    // MARK: - Tap On Non stop
    @IBAction func tapOnNonStop(_ sender: UIButton) {
        UIView.transition(with: sender as UIView, duration: 0.75, options: .transitionCrossDissolve) {
            sender.isSelected = !sender.isSelected
        } completion: { [self] isDone in
            if isPlaying {
                playPauseAudio(!sender.isSelected)
            }
            AudioPlayManager.shared.isNonStop = !sender.isSelected
            AudioPlayManager.shared.isMiniPlayerActive = !sender.isSelected
        }
    }
    
    // MARK: - SPN stands Story(0) Plot(1) and Narrotion(2)
    @IBAction func tapOnSPNButton(_ sender: UIButton) {
        Core.push(self, storyboard: Constants.Storyboard.audio, storyboardId: "AuthorViewController")
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
        
        visualizationWave.meteringLevelBarWidth = 1.0
        visualizationWave.meteringLevelBarInterItem = 1.0
        visualizationWave.audioVisualizationTimeInterval = 0.30
        visualizationWave.gradientStartColor = .black
        visualizationWave.gradientEndColor = .lightGray

        visualizationWave.reset()
        
        if existingAudio, let playerk = AudioPlayManager.shared.playerAV {
            player = playerk
            AudioPlayManager.shared.isMiniPlayerActive = true
            
            waveFormcount = AudioPlayManager.shared.audioMetering.count
            visualizationWave.meteringLevels = AudioPlayManager.shared.audioMetering
            DispatchQueue.main.async {
                self.visualizationWave.setNeedsDisplay()
                self.udpateTime()
            }
            
            if let duration = player.currentItem?.asset.duration {
                totalTimeDuration = Float(CMTimeGetSeconds(duration))
                visualizationWave.play(for: TimeInterval(totalTimeDuration))
                if let chronometer = self.visualizationWave.playChronometer, let waveformsToBeRecolored = player.currentItem?.currentTime().seconds {
                    chronometer.timerCurrentValue = TimeInterval(waveformsToBeRecolored)
                    chronometer.timerDidUpdate?(TimeInterval(waveformsToBeRecolored))
                }
            }
                        
            self.playButton.isSelected = player.isPlaying
            if player.isPlaying {
                audioTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(NowPlayViewController.udpateTime), userInfo: nil, repeats: true)
                RunLoop.main.add(self.audioTimer, forMode: .default)
                audioTimer.fire()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [self] in
                    visualizationWave.pause()
                }
            }
        } else {
            AudioPlayManager.shared.configAudio(URL(fileURLWithPath: url))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [self] in
                if let playerk = AudioPlayManager.shared.playerAV {
                    self.player = playerk
                }
            }
            
            self.playButton.isSelected = false
            Core.ShowProgress(self, detailLbl: "Getting audio waves...")
            AudioPlayManager.getAudioMeters(URL(fileURLWithPath: url), forChannel: 0) { [self] result in
                waveFormcount = result.count
                visualizationWave.meteringLevels = result
                DispatchQueue.main.async {
                    visualizationWave.setNeedsDisplay()
                    udpateTime()
                }
                if let duration = player.currentItem?.asset.duration {
                    totalTimeDuration = Float(CMTimeGetSeconds(duration))
                    visualizationWave.play(for: TimeInterval(totalTimeDuration))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [self] in
                        visualizationWave.pause()
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
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
                Core.HideProgress(self)
            }            
        }
        // Pan gesture for scrubbing support.
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGestureRecognizer.cancelsTouchesInView = false
        visualizationWave.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
            case .began:
                isPlayingTap = player.isPlaying
                if (isPlayingTap) {
                    self.playPauseAudio(false)
                }
            case .changed:
                let xLocation = Float(recognizer.location(in: self.visualizationWave).x)
                updateWaveWith(xLocation)
            case .ended:
                let xLocation = Float(recognizer.location(in: self.visualizationWave).x)
                
                if let totalAudioDuration = player.currentItem?.asset.duration {
                    let percentageInSelf = Double(xLocation / Float(self.visualizationWave.bounds.width))
                    let totalAudioDurationSeconds = CMTimeGetSeconds(totalAudioDuration)
                    let scrubbedDutation = totalAudioDurationSeconds * percentageInSelf
                    let scrubbedDutationMediaTime = CMTimeMakeWithSeconds(scrubbedDutation, preferredTimescale: 1000)
                    player.seek(to: scrubbedDutationMediaTime)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        self.udpateTime()
                    }
                }
            if (isPlayingTap) {
                self.playPauseAudio(true)
            }
            default:
                break
        }
    }
    
    private func updateWaveWith(_ location: Float) {
        let percentageInSelf = location / Float(self.visualizationWave.bounds.width)
        var waveformsToBeRecolored = Float(totalTimeDuration) * percentageInSelf
        if waveformsToBeRecolored >= totalTimeDuration {
            waveformsToBeRecolored = waveformsToBeRecolored - 1.0
        }
        if let chronometer = self.visualizationWave.playChronometer {
            chronometer.timerCurrentValue = TimeInterval(waveformsToBeRecolored)
            chronometer.timerDidUpdate?(TimeInterval(waveformsToBeRecolored))
        }
    }
    
    private func playPauseAudio(_ playing: Bool) {
        self.playButton.isSelected = playing
        isPlaying = playing
        if !playing {
            player.pause()
            audioTimer.invalidate()
            visualizationWave.pause()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "pauseAudio"), object: nil)
        } else {
            player.play()
            audioTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(NonStopViewController.udpateTime), userInfo: nil, repeats: true)
            RunLoop.main.add(self.audioTimer, forMode: .default)
            audioTimer.fire()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "playAudio"), object: nil)
            visualizationWave.play(for: TimeInterval(totalTimeDuration))
        }
    }
    
    @objc private func itemDidFinishedPlaying() {
        existingAudio = false
        configureAudio(true)
        if let chronometer = self.visualizationWave.playChronometer {
            chronometer.timerCurrentValue = TimeInterval(0)
            chronometer.timerDidUpdate?(TimeInterval(0))
        }
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
            if !duration.isNaN && (duration >= 5.0 && duration <= 6.0) {
                PromptVManager.present(self, isAudioView: true)
            }
            AudioPlayManager.shared.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playhead
            MPNowPlayingInfoCenter.default().nowPlayingInfo = AudioPlayManager.shared.nowPlayingInfo
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
//        if segue.identifier == "nonstop", let audVC = segue.destination as? AudioListViewController {
//            audVC.isNonStop = true
//        }
    }

}
