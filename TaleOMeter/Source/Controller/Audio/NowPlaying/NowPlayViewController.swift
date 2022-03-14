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
import MediaPlayer

class NowPlayViewController: UIViewController {

    // MARK: - Weak Properties -
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var audioImageView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cuncurrentUserLbl: UILabel!
    @IBOutlet weak var storyButton: UIButton!
    @IBOutlet weak var plotButton: UIButton!
    @IBOutlet weak var narrotionButton: UIButton!
    @IBOutlet weak var visualizationWave: AudioVisualizationView! {
        didSet {
            visualizationWave.meteringLevelBarWidth = 1.0
            visualizationWave.meteringLevelBarInterItem = 1.0
            visualizationWave.audioVisualizationTimeInterval = 0.30
            visualizationWave.gradientStartColor = .white
            visualizationWave.gradientEndColor = .red
        }
    }
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    // MARK: - Public Properties -
    var existingAudio = false
    var waveFormcount = 0

    // MARK: - Private Properties -
    fileprivate var totalTimeDuration: Float = 0.0
    fileprivate var audioTimer = Timer()
    fileprivate var isPlayingTap = false
    fileprivate var player = AVPlayer()
    fileprivate var audio = Audio()
    fileprivate var audioURL = URL(string: "")

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.audioImageView.cornerRadius = self.audioImageView.frame.size.height / 2.0
        
        if let audList = AudioPlayManager.shared.audioList, AudioPlayManager.shared.currentAudio >= 0 {
            audio = audList[AudioPlayManager.shared.currentAudio]
            // Configure audio data
            setupAudioData(false)
        } else {
            Snackbar.showErrorMessage("Selected Audio not found!")
        }
                
        // Set notification center for audio playing completed
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishedPlaying), name: NSNotification.Name(rawValue: "FinishedPlaying"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(remoteCommandHandler(_:)), name: remoteCommandName, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true, titleInLeft: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.audioImageView.cornerRadius = self.audioImageView.frame.size.height / 2.0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        audioTimer.invalidate()
    }
    
    //MARK: - Call funcation when audio controller press in background
    @objc private func remoteCommandHandler(_ notification: Notification) {
        if let isPlay = notification.userInfo?["isPlaying"] as? Bool {
            self.playPauseAudio(isPlay)
        } else if let isNext = notification.userInfo?["isNext"] as? Bool {
            seekAudio(isNext)
        }
    }
    
    // MARK: Set audio data
    private func setupAudioData(_ playNow: Bool) {
        //guard let url = Bundle.main.url(forResource: "file_example_MP3_5MG", withExtension: "mp3") else { return }
        AudioPlayManager.shared.isNonStop = false
        
        self.imageView.image = audio.Image
        self.titleLabel.text = audio.Title
        self.storyButton.setTitle("Story: \(audio.Story.Name)", for: .normal)
        self.storyButton.setTitle("Plot: \(audio.Plot.Name)", for: .normal)
        self.storyButton.setTitle("Narration: \(audio.Narration.Name)", for: .normal)
        
        self.cuncurrentUserLbl.text = "Concurrent Users: \(audio.Views_count.formatPoints())"
                
        if existingAudio {
            setupExistingAudio()
        } else {
            if let player = AudioPlayManager.shared.playerAV {
                player.pause()
            }
            Core.ShowProgress(self, detailLbl: "Streaming Audio")
            
            AudioPlayManager.shared.initPlayerManager { result in
                self.configureAudio(playNow, result: result)
                Core.HideProgress(self)
            }
        }
    }
    
    // MARK: - Playing existing Audio
    private func setupExistingAudio() {
        if let playerk = AudioPlayManager.shared.playerAV {
            player = playerk
            
            // Reset visulization wave
            self.visualizationWave.reset()
            
            // Set waveform count
            waveFormcount = AudioPlayManager.shared.audioMetering.count
            
            // Set merering level of wave
            visualizationWave.meteringLevels = AudioPlayManager.shared.audioMetering
            
            // Update time duration in label
            self.visualizationWave.setNeedsDisplay()
            
            // Get audio duration play at current audio duration
            if let duration = player.currentItem?.asset.duration {
                totalTimeDuration = Float(CMTimeGetSeconds(duration))
                if self.visualizationWave.playChronometer == nil {
                    visualizationWave.setplayChronometer(for: TimeInterval(totalTimeDuration))
                }
                if let chronometer = self.visualizationWave.playChronometer, let waveformsToBeRecolored = player.currentItem?.currentTime().seconds {
                    chronometer.timerCurrentValue = TimeInterval(waveformsToBeRecolored)
                    chronometer.timerDidUpdate?(TimeInterval(waveformsToBeRecolored))
                }
            }
            self.playPauseAudio(player.isPlaying)
        }
    }
    
    //  MARK: - Set up audio wave and play
    private func configureAudio(_ playNow: Bool, result: [Float]) {
        DispatchQueue.main.async { [self] in
            // Reset visulization wave
            self.visualizationWave.reset()
            if let playerk = AudioPlayManager.shared.playerAV {
                // Set player private variable
                player = playerk
                
                // setup waveform count
                waveFormcount = result.count
                
                // Setup mereting levels of visulationview
                visualizationWave.meteringLevels = result
                visualizationWave.setNeedsDisplay()
                
                // Get audio duration and set in private variable
                if let duration = player.currentItem?.asset.duration {
                    // Totalvidio duration
                    totalTimeDuration = Float(CMTimeGetSeconds(duration))
                    
                    // Setup chrono meter befor playing video
                    if playNow {
                        self.visualizationWave.playChronometer = nil
                    } else if self.visualizationWave.playChronometer == nil {
                        visualizationWave.setplayChronometer(for: TimeInterval(totalTimeDuration))
                    }
                    self.playPauseAudio(playNow)
                }
            }
            // Pan gesture for scrubbing support.
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            panGestureRecognizer.cancelsTouchesInView = false
            visualizationWave.addGestureRecognizer(panGestureRecognizer)
        }
    }
    
    // MARK: - Play next or previous audio
    private func nextPrevPlay(_ isNext: Bool = true) {
        // Check current audio supported or not
        var isSupported = true
        if let audioUrl = URL(string: AudioPlayManager.shared.audioList![isNext ? AudioPlayManager.shared.nextAudio : AudioPlayManager.shared.prevAudio].File) {
            let fileName = NSString(string: audioUrl.lastPathComponent)
            if !supportedAudioExtenstion.contains(fileName.pathExtension.lowercased()) {
                Snackbar.showErrorMessage("Audio File \"\(fileName)\" is not supported!")
                isSupported = false
            }
        }
        
        // Set current auio index
        let currentAudio = isNext ? AudioPlayManager.shared.nextAudio : AudioPlayManager.shared.prevAudio
        guard let audioList = AudioPlayManager.shared.audioList else {
            Snackbar.showAlertMessage("No next audio found!")
            return
        }
        
        //Set up next previous audio index
        AudioPlayManager.shared.currentAudio = currentAudio
        AudioPlayManager.shared.nextAudio = audioList.count - 1 > currentAudio ? currentAudio + 1 : 0
        AudioPlayManager.shared.prevAudio = currentAudio > 0 ? currentAudio - 1 : audioList.count - 1
        audio = audioList[currentAudio]
        
        if isSupported {
            // Configure audio data
            self.existingAudio = false
            setupAudioData(true)
        } else {
            // Check next or previous audio
            self.nextPrevPlay(isNext)
        }
    }

    // MARK: - When swipe wave handle here
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
    
    // MARK: - Update wave as per swipe
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
    
    // MARK: - Handle play pause audio
    private func playPauseAudio(_ playing: Bool) {
        DispatchQueue.main.async {
            self.playButton.isSelected = playing
        }
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
            if sender.isSelected {
                self.removeFromFav(audio.Story_id) { status in
                    if let st = status, st {
                        sender.isSelected = !sender.isSelected
                    }
                }
            } else {
                self.addToFav(audio.Story_id) { status in
                    if let st = status, st {
                        sender.isSelected = !sender.isSelected
                    }
                }
            }
            break
        case 3:
            //Back 10 Second
            seekAudio(false)
            break;
        case 4:
            //Forward 10 Second
            seekAudio(true)
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
    
    // MARK: - Seek audio time
    private func seekAudio(_ forward: Bool) {
        if forward {
            guard let duration  = player.currentItem?.duration else {
                    return
            }
            let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
            let newTime = playerCurrentTime + 10

            if newTime < CMTimeGetSeconds(duration) {
                let time2: CMTime = CMTimeMake(value: Int64(newTime) * 1000, timescale: 1000)
                player.seek(to: time2)
                setTime(newTime)
            } else {
                let time2: CMTime = CMTimeMake(value: Int64(CMTimeGetSeconds(duration)) * 1000, timescale: 1000)
                player.seek(to: time2)
                setTime(newTime)
            }
        } else {
            let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
            var newTime = playerCurrentTime - 10
            if newTime < 0 {
                newTime = 0
            }
            let time2: CMTime = CMTimeMake(value: Int64(newTime) * 1000, timescale: 1000)
            player.seek(to: time2)
            setTime(newTime)
        }
    }
    
    @objc private func itemDidFinishedPlaying() {
        // Configure audio data
//        existingAudio = false
//        setupAudioData(false)
    }
    
    // MARK: - Set start and end time
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
    
    // MARK: - Update time as per playing audio
    @objc func udpateTime() {
        if let currentItem = player.currentItem {
            DispatchQueue.main.async { [self] in
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
                    if player.isPlaying && (duration >= 5.0 && duration <= 6.0) {
                        PromptVManager.present(self, verifyTitle: audio.Title, verifyMessage: AudioPlayManager.shared.audioList![AudioPlayManager.shared.nextAudio].Title, image: nil, isAudioView: true, audioImage: AudioPlayManager.shared.audioList![AudioPlayManager.shared.nextAudio].Image)
                    }
                }
                AudioPlayManager.shared.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playhead
                MPNowPlayingInfoCenter.default().nowPlayingInfo = AudioPlayManager.shared.nowPlayingInfo
            }
        }
    }
}

extension NowPlayViewController {
    // Add to favourite
    private func addToFav(_ audio_story_id: Int, completion: @escaping(Bool?) -> Void) {
        Core.ShowProgress(self, detailLbl: "")
        FavouriteAudioClient.add(FavouriteRequest(audio_story_id: audio_story_id)) { status in
            Core.HideProgress(self)
            completion(status)
        }
    }
    
    // Remove from favourite
    private func removeFromFav(_ audio_story_id: Int, completion: @escaping(Bool?) -> Void) {
        Core.ShowProgress(self, detailLbl: "")
        FavouriteAudioClient.remove(FavouriteRequest(audio_story_id: audio_story_id)) { status in
            Core.HideProgress(self)
            completion(status)
        }
    }
}

// MARK: - PromptViewDelegate -
extension NowPlayViewController: PromptViewDelegate {
    func didActionOnPromptButton(_ tag: Int) {
        switch tag {
        case 0:
            //0 - Add to fav
            self.addToFav(audio.Story_id) { status in }
            break
        case 1:
            //1 - Once more
            self.player.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: 1000))
            self.visualizationWave.stop()
            self.existingAudio = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.setupAudioData(false)
            }
            break
        default:
            //2 - play next song
            playPauseAudio(false)
            visualizationWave.stop()
            nextPrevPlay()
            break
        }
    }
}
