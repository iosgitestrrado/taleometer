//
//  NowPlayViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit
import SoundWave
import CoreMedia
import AVFoundation

class NowPlayViewController: UIViewController {

    // MARK: - Weak Properties -
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var storyButton: UIButton!
    @IBOutlet weak var plotButton: UIButton!
    @IBOutlet weak var narrotionButton: UIButton!
    @IBOutlet weak var storyNameLabel: UILabel!
    @IBOutlet weak var plotNameLabel: UILabel!
    @IBOutlet weak var narrotionNameLabel: UILabel!
    @IBOutlet weak var visualizationWave: AudioVisualizationView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    // MARK: - Public Properties -
    public var existingAudio = false

    // MARK: - Private Properties -
    public var waveFormcount = 0
    private var totalTimeDuration: Float = 0.0
    private var audioTimer = Timer()
    private var isPlayingTap = false
    private var player = AVPlayer()

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureAudio()
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishedPlaying), name: NSNotification.Name(rawValue: "FinishedPlaying"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.imageView.cornerRadius = self.imageView.frame.size.height / 2.0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        audioTimer.invalidate()
    }
    
    // MARK: Set audio wave meter
    private func configureAudio() {
        //guard let url = Bundle.main.url(forResource: "file_example_MP3_5MG", withExtension: "mp3") else { return }
        AudioPlayManager.shared.isNonStop = false
        guard let url = Bundle.main.path(forResource: "testAudio", ofType: "mp3") else { return }
        
        visualizationWave.audioVisualizationMode = .write
        visualizationWave.add(meteringLevel: 0.6)

        visualizationWave.meteringLevelBarWidth = 1.0
        visualizationWave.meteringLevelBarInterItem = 1.0
        visualizationWave.audioVisualizationTimeInterval = 0.30
        visualizationWave.gradientStartColor = .white
        visualizationWave.gradientEndColor = .red

        visualizationWave.reset()
        if existingAudio, let playerk = AudioPlayManager.shared.playerAV {
            player = playerk
            AudioPlayManager.shared.isMiniPlayerActive = true
            waveFormcount = AudioPlayManager.shared.audioMetering.count
            visualizationWave.audioVisualizationMode = .read
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
            Core.ShowProgress(contrSelf: self, detailLbl: "Getting audio waves...")
            AudioPlayManager.getAudioMeters(URL(fileURLWithPath: url), forChannel: 0) { [self] result in
                waveFormcount = result.count
                visualizationWave.audioVisualizationMode = .read
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
                Core.HideProgress(contrSelf: self)
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
    
    private func playPauseAudio(_ playing: Bool) {
        self.playButton.isSelected = playing
        if !playing {
            player.pause()
            audioTimer.invalidate()
            visualizationWave.pause()
        } else {
            player.play()
            audioTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(NowPlayViewController.udpateTime), userInfo: nil, repeats: true)
            RunLoop.main.add(self.audioTimer, forMode: .default)
            audioTimer.fire()
            visualizationWave.play(for: TimeInterval(totalTimeDuration))
        }
    }
    
    // MARK: - Play(0) Previouse(1) Favourite(2) Back10Sec(3) Forward10Sec(4) Share(5)
    @IBAction func tapOnAudioController(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            //Play
            self.playPauseAudio(!player.isPlaying)
            break
        case 1:
            //Previouse
            itemDidFinishedPlaying()
            break
        case 2:
            //Favourite
            sender.isSelected = !sender.isSelected
            break
        case 3:
            //Back 10 Second
            let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
            var newTime = playerCurrentTime - 10
            if newTime < 0 {
                newTime = 0
            }
            let time2: CMTime = CMTimeMake(value: Int64(newTime) * 1000, timescale: 1000)
            player.seek(to: time2)
            setTime(newTime)
            break;
        case 4:
            //Forward 10 Second
            guard let duration  = player.currentItem?.duration else {
                    return
            }
            let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
            let newTime = playerCurrentTime + 10

            if newTime < CMTimeGetSeconds(duration) {
                let time2: CMTime = CMTimeMake(value: Int64(newTime) * 1000, timescale: 1000)
                player.seek(to: time2)
                setTime(newTime)
            }
            break
        default:
            //Share
            let content = "Introducing tele'o'meter, An App that simplifies audio player for Every One. \nClick here to play audio http://google.co.in/"
            let controller = UIActivityViewController(activityItems: [content], applicationActivities: nil)
            controller.excludedActivityTypes = [.postToTwitter, .postToFacebook, .postToWeibo, .message, .mail, .print, .copyToPasteboard, .assignToContact, .saveToCameraRoll, .addToReadingList, .postToVimeo, .postToFlickr, .postToTencentWeibo, .airDrop, .markupAsPDF, .openInIBooks]
            self.present(controller, animated: true, completion: nil)
            break
        }
    }
    
    @objc private func itemDidFinishedPlaying() {
        //if (player.isPlaying) {
            self.playPauseAudio(false)
        //}
        existingAudio = false
        configureAudio()
        if let chronometer = self.visualizationWave.playChronometer {
            chronometer.timerCurrentValue = TimeInterval(0)
            chronometer.timerDidUpdate?(TimeInterval(0))
        }
    }
    
    private func setTime(_ currentTime: TimeInterval) {
        let playhead = currentTime
        let duration = TimeInterval(totalTimeDuration) - currentTime
        if !playhead.isNaN {
            self.startTimeLabel.text = AudioPlayManager.formatTimeFor(seconds: playhead)
        }
        if !duration.isNaN {
            self.endTimeLabel.text = AudioPlayManager.formatTimeFor(seconds: duration)
        }
        if let chronometer = self.visualizationWave.playChronometer {
            chronometer.timerCurrentValue = currentTime
            chronometer.timerDidUpdate?(currentTime)
        }
    }
    
    @objc func udpateTime() {
        if let currentItem = player.currentItem {
            // Get the current time in seconds
            let playhead = currentItem.currentTime().seconds
            let duration = currentItem.duration.seconds - currentItem.currentTime().seconds
            // Format seconds for human readable string
            if !playhead.isNaN {
                if playhead > 0 {
                    self.startTimeLabel.text = AudioPlayManager.formatTimeFor(seconds: playhead + 1)
                } else {
                    self.startTimeLabel.text = AudioPlayManager.formatTimeFor(seconds: playhead)
                }
            }
            if !duration.isNaN {
                self.endTimeLabel.text = AudioPlayManager.formatTimeFor(seconds: duration)
                if (duration >= 5.0 && duration <= 6.0) {
                    PromptVManager.present(self)
                }
            }
        }
    }
}

// MARK: - PromptViewDelegate -
extension NowPlayViewController: PromptViewDelegate {
    func didActionOnPromptButton(_ tag: Int) {
        switch tag {
        case 0:
            //0 - Add to fav
            break
        case 1:
            //1 - Once more
            itemDidFinishedPlaying()
            break
        default:
            //2 - play next song
            itemDidFinishedPlaying()
            break
        }
    }
}

