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
    @IBOutlet weak var visualizationWave: AudioVisualizationView! {
        didSet {
            visualizationWave.meteringLevelBarWidth = 1.0
            visualizationWave.meteringLevelBarInterItem = 1.0
            visualizationWave.audioVisualizationTimeInterval = 0.30
            visualizationWave.gradientStartColor = .black
            visualizationWave.gradientEndColor = .lightGray
        }
    }
    
    // MARK: - Public Properties -
    var existingAudio = false
    var isPlayingExisting = false
    var waveFormcount = 0

    // MARK: - Private Properties -
    private var totalTimeDuration: Float = 0.0
    private var audioTimer = Timer()
    private var isPlaying = false
    private var player = AVPlayer()
    private var isPlayingTap = false
    private var audio = Audio()
    private var audioURL = URL(string: "")
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        getAudioList()
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishedPlaying), name: AudioPlayManager.finishNotification, object: nil)
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
    
    // Get non stop audio
    private func getAudioList() {
        if existingAudio {
            setupExistingAudio(isPlayingExisting)
            if let audList = AudioPlayManager.shared.audioList, AudioPlayManager.shared.currentAudio >= 0 {
                audio = audList[AudioPlayManager.shared.currentAudio]
                self.audioTitle.text = audio.Title
                self.storyLabel.setTitle("Story: \(audio.Story.Name)", for: .normal)
                self.plotLabel.setTitle("Plot: \(audio.Plot.Name)", for: .normal)
                self.narrotionLabel.setTitle("Narration: \(audio.Narration.Name)", for: .normal)
                self.favButton.isSelected = favouriteAudio.contains(where: { $0.Id == audio.Id })
            }
        } else {
            if !Reachability.isConnectedToNetwork() {
                Toast.show()
                return
            }
            Core.ShowProgress(self, detailLbl: "Getting Audio...")
            AudioClient.get(AudioRequest(page: 1, limit: 10), isNonStop: true, completion: { [self] result in
                if let response = result {
                    var currentIndex = -1
                    for idx in 0..<response.count {
                        if let audioUrl = URL(string: response[idx].File) {
                            let fileName = NSString(string: audioUrl.lastPathComponent)
                            if supportedAudioExtenstion.contains(fileName.pathExtension.lowercased()) {
                                currentIndex = idx
                                break
                            }
                        }
                    }
                    
                    if currentIndex >= 0 {
                        AudioPlayManager.shared.audioList = response
                        AudioPlayManager.shared.currentAudio = currentIndex
                        AudioPlayManager.shared.nextAudio = response.count - 1 > currentIndex ? currentIndex + 1 : 0
                        AudioPlayManager.shared.prevAudio = currentIndex > 0 ? currentIndex - 1 : response.count
                        if let audList = AudioPlayManager.shared.audioList, AudioPlayManager.shared.currentAudio >= 0 {
                            audio = audList[AudioPlayManager.shared.currentAudio]
                            // Configure audio data
                            Core.HideProgress(self)
                            setupAudioData(false)
                            return
                        }
                    }
                    Toast.show("Audio not found!")
                }
                Core.HideProgress(self)
            })
        }
    }
    
    // MARK: Set audio data
    private func setupAudioData(_ playNow: Bool) {
        self.audioTitle.text = audio.Title
        self.storyLabel.setTitle("Story: \(audio.Story.Name)", for: .normal)
        self.plotLabel.setTitle("Plot: \(audio.Plot.Name)", for: .normal)
        self.narrotionLabel.setTitle("Narration: \(audio.Narration.Name)", for: .normal)
        self.favButton.isSelected = favouriteAudio.contains(where: { $0.Id == audio.Id })
        
        if existingAudio {
            setupExistingAudio(playNow)
        } else {
            if let player = AudioPlayManager.shared.playerAV {
                player.pause()
            }
            Core.ShowProgress(self, detailLbl: "Streaming Audio")
            AudioPlayManager.shared.initPlayerManager(isNonStop: true) { result in
                self.configureAudio(playNow, result: result)
                Core.HideProgress(self)
            }
        }
    }
    
    // MARK: - Playing existing Audio
    private func setupExistingAudio(_ playNow: Bool) {
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
            self.playPauseAudio(playNow)
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
            if player.isPlaying {
                playPauseAudio(false)
                visualizationWave.stop()
            }
            self.nextPrevPlay(player.isPlaying)
            break
        default:
            //Favourite
            if sender.isSelected {
                self.removeFromFav(audio.Id) { status in
                    if let st = status, st {
                        sender.isSelected = !sender.isSelected
                    }
                }
            } else {
                self.addToFav(audio.Id) { status in
                    if let st = status, st {
                        sender.isSelected = !sender.isSelected
                    }
                }
            }
            break
        }
    }
    
    // MARK: - Play next or previous audio
    private func nextPrevPlay(_ isNext: Bool = true) {
        // Setup audio index
        AudioPlayManager.shared.setAudioIndex(isNext: isNext)
        
        // No existing audio play
        self.existingAudio = false
        
        // Setup current audio variable
        self.audio = AudioPlayManager.shared.audio
        
        // Configure audio data
        setupAudioData(player.isPlaying)
        
        // Current player pause and visualization wave stop
        if player.isPlaying {
            playPauseAudio(false)
            visualizationWave.stop()
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
    
    // MARK: - Handle audio play and pause
    private func playPauseAudio(_ playing: Bool) {
        self.playButton.isSelected = playing
        isPlaying = playing
        if !playing {
            player.pause()
            audioTimer.invalidate()
            visualizationWave.pause()
            //NotificationCenter.default.post(name: Notification.Name(rawValue: "pauseAudio"), object: nil)
        } else {
            player.play()
            audioTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(NonStopViewController.udpateTime), userInfo: nil, repeats: true)
            RunLoop.main.add(self.audioTimer, forMode: .default)
            audioTimer.fire()
            //NotificationCenter.default.post(name: Notification.Name(rawValue: "playAudio"), object: nil)
            visualizationWave.play(for: TimeInterval(totalTimeDuration))
        }
    }
    
    // MARK: - One audio playing completed
    @objc private func itemDidFinishedPlaying() {
        // Configure audio data
//        existingAudio = false
//        setupAudioData(false)
    }
    
    // MARK: - Set start and end time
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
                PromptVManager.present(self, verifyTitle: audio.Title, verifyMessage: AudioPlayManager.shared.audioList![AudioPlayManager.shared.nextAudio].Title, image: nil, ansImage: nil, isAudioView: true, audioImage: AudioPlayManager.shared.audioList![AudioPlayManager.shared.nextAudio].Image)
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

extension NonStopViewController {
    // Add to favourite
    private func addToFav(_ audio_story_id: Int, completion: @escaping(Bool?) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Toast.show()
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        FavouriteAudioClient.add(FavouriteRequest(audio_story_id: audio_story_id)) { status in
            Core.HideProgress(self)
            completion(status)
        }
    }
    
    // Remove from favourite
    private func removeFromFav(_ audio_story_id: Int, completion: @escaping(Bool?) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Toast.show()
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        FavouriteAudioClient.remove(FavouriteRequest(audio_story_id: audio_story_id)) { status in
            Core.HideProgress(self)
            completion(status)
        }
    }
}


// MARK: - PromptViewDelegate -
extension NonStopViewController: PromptViewDelegate {
    func didActionOnPromptButton(_ tag: Int) {
        switch tag {
        case 0:
            //0 - Add to fav
            self.addToFav(audio.Id) { status in }
            break
        case 1, 3:
            //1 - Once more //3 - Close mini player
            self.player.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: 1000))
            self.visualizationWave.stop()
            self.player.pause()
            self.existingAudio = true
            self.setupAudioData(tag == 1)
        default:
            //2 - play next song
            nextPrevPlay()
            break
        }
    }
}
