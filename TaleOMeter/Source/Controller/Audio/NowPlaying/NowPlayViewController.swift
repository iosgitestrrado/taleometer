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
import CallKit

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
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var backBarButton: UIButton!

    // MARK: - Public Properties -
    var existingAudio = false
    var isPlaying = true
    var waveFormcount = 0
    var myAudioList = [Audio]()
    var currentAudioIndex = -1
    var currentPlayDuration = -1
    var storyIdis = -1
    var isFromNotification = false
    
    // MARK: - Private Properties -
    private var totalTimeDuration: Float = 0.0
    private var audioTimer = Timer()
    private var isPlayingTap = false
    private var currentAudio = Audio()
    private var audioURL = URL(string: "")
    
    let yourAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
      ] 

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.audioImageView.cornerRadius = self.audioImageView.frame.size.height / 2.0
        self.imageView.cornerRadius = self.imageView.frame.size.height / 2.0
        self.backBarButton.isHidden = true// storyId == -1
        if let audList = AudioPlayManager.shared.audioList, audList.count > 0, AudioPlayManager.shared.currentIndex >= 0 {
            currentAudio = audList[AudioPlayManager.shared.currentIndex]
            AudioPlayManager.shared.audioHistoryId = -1
            // Configure audio data
            setupAudioDataPlay(isPlaying)
        } else if storyId != -1 {
            self.getAudios(storyIdis)
        } else {
            Toast.show("Selected Audio not found!")
        }
        
        // Pan gesture for scrubbing support.
//        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
//        panGestureRecognizer.cancelsTouchesInView = false
//        visualizationWave.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true, titleInLeft: false)
        
        // Set notification center for audio playing completed
        NotificationCenter.default.addObserver(self, selector: #selector(remoteCommandHandler(_:)), name: remoteCommandName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishedPlaying(_:)), name: AudioPlayManager.finishNotification, object: nil)
        AudioPlayManager.shared.isNowPlayPage = true
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioTimer.invalidate()
        AudioPlayManager.shared.isNowPlayPage = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.audioImageView.cornerRadius = self.audioImageView.frame.size.height / 2.0
        self.imageView.cornerRadius = self.imageView.frame.size.height / 2.0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // When moved to other screen stop audio player time
        audioTimer.invalidate()
        // Pause wave
//        visualizationWave.pause()
    }
    
    @IBAction func tapOnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Call funcation when audio controller press in background
    @objc private func remoteCommandHandler(_ notification: Notification) {
        // Check audio is playing
        if (notification.userInfo?["isPlaying"] as? Bool) != nil {
            // Play pause audio wave
            self.playPauseWave()
        } else if let isfrwdback = notification.userInfo?["isForwardBackward"] as? Bool, isfrwdback {
            if let isNext = notification.userInfo?["isNext"] as? Bool {
                // Seek audio
                seekAudio(isNext)
            }
        } else if let notificationStoryId = notification.userInfo?["NotificationStoryId"] as? Int, notificationStoryId != -1 {
            if let playCurrent = notification.userInfo?["PlayCurrent"] as? Bool {
                if playCurrent, let audList = AudioPlayManager.shared.audioList, AudioPlayManager.shared.currentIndex >= 0 {
                    currentAudio = audList[AudioPlayManager.shared.currentIndex]
                    AudioPlayManager.shared.audioHistoryId = -1
                    // Configure audio data
                    setupAudioDataPlay(isPlaying)
                } else {
                    self.getAudios(notificationStoryId)
                }
            }
        }
    }
    
    // MARK: - When audio playing is finished -
    @objc private func itemDidFinishedPlaying(_ notification: Notification) {
        if !isFromNotification, AudioPlayManager.shared.isNowPlayPage, UserDefaults.standard.bool(forKey: "AutoplayEnable"), let aList = AudioPlayManager.shared.audioList, aList.count > 0 {
            PromptVManager.present(self, verifyTitle: currentAudio.Title, verifyMessage: aList[AudioPlayManager.shared.nextIndex].Title, isAudioView: true, audioImage: aList[AudioPlayManager.shared.nextIndex].ImageUrl)
        } else {
            self.playPauseAudio(false)
            self.playPauseWave()
        }
    }
    
    // MARK: Set audio data only
    private func setAudioData() {
        self.imageView.sd_setImage(with: URL(string: currentAudio.ImageUrl), placeholderImage: defaultImage, options: [], context: nil)
        self.titleLabel.text = currentAudio.Title
        
        let attributeString = NSMutableAttributedString(
              string: "Story: \(currentAudio.Story.Name)",
              attributes: yourAttributes
            )
        self.storyButton.setAttributedTitle(attributeString, for: .normal)
        
        let attributeString1 = NSMutableAttributedString(
              string: "Plot: \(currentAudio.Plot.Name)",
              attributes: yourAttributes
            )
        self.plotButton.setAttributedTitle(attributeString1, for: .normal)
        
        let attributeString2 = NSMutableAttributedString(
              string: "Narration: \(currentAudio.Narration.Name)",
              attributes: yourAttributes
            )
        self.narrotionButton.setAttributedTitle(attributeString2, for: .normal)
        
//        self.storyButton.setTitle("Story: \(currentAudio.Story.Name)", for: .normal)
//        self.plotButton.setTitle("Plot: \(currentAudio.Plot.Name)", for: .normal)
//        self.narrotionButton.setTitle("Narration: \(currentAudio.Narration.Name)", for: .normal)
        
        self.cuncurrentUserLbl.text = "Concurrent Users: \(currentAudio.Views_count.formatPoints())"
        self.favButton.isSelected = currentAudio.Is_favorite
        
        self.audioImageView.cornerRadius = self.audioImageView.frame.size.height / 2.0
        self.imageView.cornerRadius = self.imageView.frame.size.height / 2.0
    }
    
    // MARK: Set audio data and play audio
    private func setupAudioDataPlay(_ playNow: Bool) {
        //guard let url = Bundle.main.url(forResource: "file_example_MP3_5MG", withExtesnsion: "mp3") else { return }
        // Set non stop false for mini player
        AudioPlayManager.shared.isNonStop = false
        
        // Set audio data like image, title, story etc..
        setAudioData()
        
        // Check if existing audio want to play
        if existingAudio {
            // Setup existing audio
            setupExistingAudio(playNow)
        } else {
            // Pause audio
            AudioPlayManager.shared.playPauseAudioOnly(false, addToHistory: false)
            
            // Start progress
            Core.ShowProgress(self, detailLbl: "Streaming Audio", isUserInterface: false)
            
            // Initialize audio play in audio player manager
            AudioPlayManager.shared.initPlayerManager { result in
                // Config audio in current view
                self.configureAudio(playNow, result: result)
                
                // Hide progress
                Core.HideProgress(self)
            }
        }
    }
    
    // MARK: - Playing existing Audio
    private func setupExistingAudio(_ playNow: Bool) {
        if let player = AudioPlayManager.shared.playerAV {
            
            // Reset visulization wave
            self.visualizationWave.reset()
            
            // Set waveform count
            waveFormcount = AudioPlayManager.shared.audioMetering.count
            
            // Set merering level of wave
            visualizationWave.meteringLevels = AudioPlayManager.shared.audioMetering
            
            // Update time duration in label
            self.visualizationWave.setNeedsDisplay()
            
            if currentPlayDuration >= 0, let durr = player.currentItem?.duration.seconds,  currentPlayDuration != Int(durr) {
                let scrubbedDutationMediaTime = CMTimeMakeWithSeconds(Float64(currentPlayDuration), preferredTimescale: 1000)
                player.seek(to: scrubbedDutationMediaTime)
            }
            
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
            if !playNow {
                self.udpateTime()
            }
            self.playPauseAudio(playNow)
        }
    }
    
    //  MARK: - Set up audio wave and play
    private func configureAudio(_ playNow: Bool, result: [Float]) {
        DispatchQueue.main.async { [self] in
            // Reset visulization wave
            self.visualizationWave.reset()
            if let player = AudioPlayManager.shared.playerAV {
                // setup waveform count
                waveFormcount = result.count
                
                // Setup mereting levels of visulationview
                visualizationWave.meteringLevels = result
                visualizationWave.setNeedsDisplay()
                
                if currentPlayDuration >= 0, let durr = player.currentItem?.duration.seconds,  currentPlayDuration != Int(durr) {
                    let scrubbedDutationMediaTime = CMTimeMakeWithSeconds(Float64(currentPlayDuration), preferredTimescale: 1000)
                    player.seek(to: scrubbedDutationMediaTime)
                } else if playNow {
                    self.visualizationWave.playChronometer = nil
                }
                
                // Get audio duration and set in private variable
                if let duration = player.currentItem?.asset.duration {
                    // Totalvidio duration
                    totalTimeDuration = Float(CMTimeGetSeconds(duration))
                    
                    // Setup chrono meter befor playing video
                    if playNow && currentPlayDuration == -1 {
                        self.visualizationWave.playChronometer = nil
                    } else if self.visualizationWave.playChronometer == nil {
                        self.udpateTime()
                    }
                    visualizationWave.setplayChronometer(for: TimeInterval(totalTimeDuration))
                    self.playPauseAudio(playNow)
                }
            }
        }
    }
    
    // MARK: - Play next or previous audio
    private func nextPrevPlay(_ isNext: Bool = true) {
        if let player = AudioPlayManager.shared.playerAV {
            // Current player pause and visualization wave stop
            visualizationWave.stop()
        
            // Setup audio index
            AudioPlayManager.shared.setAudioIndex(isNext: isNext)
            
            // No existing audio play
            self.existingAudio = false
            
            // Setup current audio variable
            self.currentAudio = AudioPlayManager.shared.currentAudio
        
            // Configure audio data
            setupAudioDataPlay(isNext ? true : player.isPlaying)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let touch = touches.first, touch.view == self.visualizationWave {
//            if let player = AudioPlayManager.shared.playerAV {
//                isPlayingTap = player.isPlaying
//                if (isPlayingTap) {
//                    player.pause()
//                }
//            }
//        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, touch.view == self.visualizationWave {
            let xLocation = Float(touch.location(in: self.visualizationWave).x)
            updateWaveWith(xLocation)
            // do something with your currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, touch.view == self.visualizationWave {
            let xLocation = Float(touch.location(in: self.visualizationWave).x)
            updateWaveWith(xLocation)
            if let player = AudioPlayManager.shared.playerAV {
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
//                if (isPlayingTap) {
//                    player.play()
//                }
            }
            // do something with your currentPoint
        }
    }

    // MARK: - When swipe wave handle here
    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        if let player = AudioPlayManager.shared.playerAV {
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
        let authorView = UIStoryboard(name: Constants.Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: AuthorViewController().className) as! AuthorViewController
        authorView.delegate = self
        authorView.currentAudio = currentAudio
        switch sender.tag {
        case 0:
            //Story
            authorView.isStroy = true
            authorView.storyData = currentAudio.Story
            break
        case 1:
            //Plot
            authorView.isPlot = true
            authorView.storyData = currentAudio.Plot
            break
        default:
            //Narrotion
            authorView.isNarration = true
            authorView.storyData = currentAudio.Narration
            break
        }
        self.navigationController?.pushViewController(authorView, animated: true)
    }
    
    private func playPauseWave() {
        if let player = AudioPlayManager.shared.playerAV {
            if !player.isPlaying {
                if audioTimer.isValid {
                    audioTimer.invalidate()
                }
                audioTimer = Timer(timeInterval: 0.25, target: self, selector: #selector(self.udpateTime), userInfo: nil, repeats: true)
                RunLoop.main.add(self.audioTimer, forMode: .default)
                audioTimer.fire()
//                if let ch = visualizationWave.playChronometer, !ch.isPlaying {
//                    visualizationWave.play(for: TimeInterval(totalTimeDuration))
//                }
            } else {
                audioTimer.invalidate()
//                visualizationWave.pause()
            }
            self.playButton.isSelected = !player.isPlaying
        }
    }
    
    // MARK: - Handle play pause audio
    private func playPauseAudio(_ playing: Bool) {
       // if let player = AudioPlayManager.shared.playerAV {
            AudioPlayManager.shared.playPauseAudioOnly(playing)
            //print("Audio is playing: \(playing)")
            DispatchQueue.main.async {
                self.playButton.isSelected = playing
            }
            if !playing {
                audioTimer.invalidate()
//                visualizationWave.pause()
            } else {
                //player.play()
                audioTimer = Timer(timeInterval: 0.25, target: self, selector: #selector(self.udpateTime), userInfo: nil, repeats: true)
                RunLoop.main.add(self.audioTimer, forMode: .default)
                audioTimer.fire()
//                visualizationWave.play(for: TimeInterval(totalTimeDuration))
            }
        NotificationCenter.default.post(name: AudioPlayManager.favPlayNotification, object: nil, userInfo: ["isPlaying": playing])
        //}
    }
    
    // MARK: - Play(0) Previouse(1) Favourite(2) Back10Sec(3) Forward10Sec(4) Share(5)
    @IBAction func tapOnAudioController(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            //Play
            if let player = AudioPlayManager.shared.playerAV {
                self.playPauseAudio(!player.isPlaying)
            }
            break
        case 1:
            //Previouse song
            nextPrevPlay(false)
            break
        case 2:
            //Favourite
            if sender.isSelected {
                sender.isSelected = false
                self.removeFromFav(currentAudio.Id) { status in }
            } else {
                self.addToFav(currentAudio.Id) { status in }
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
            AudioPlayManager.shareAudio(self) { status in  }
            break
        }
    }
    
    // MARK: - Seek audio time
    private func seekAudio(_ forward: Bool) {
        if let player = AudioPlayManager.shared.playerAV {
            if forward {
                guard let duration = player.currentItem?.duration else {
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
    
    func checkForActiveCall() -> Bool {
        for call in CXCallObserver().calls {
            if call.hasEnded == false {
                return true
            }
        }
        return false
    }

    @objc private func checkActiveCall() {
        if !self.checkForActiveCall() {
            audioTimer.invalidate()
            self.playPauseAudio(true)
        }
    }
    
    // MARK: - Update time as per playing audio
    @objc private func udpateTime() {
        if self.checkForActiveCall() {
            self.playPauseAudio(false)
            audioTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(NowPlayViewController.checkActiveCall), userInfo: nil, repeats: true)
            RunLoop.main.add(self.audioTimer, forMode: .default)
            audioTimer.fire()
            return
        }
        if let player = AudioPlayManager.shared.playerAV, let currentItem = player.currentItem {
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
                    if let chronometer = self.visualizationWave.playChronometer {
                        chronometer.timerCurrentValue = TimeInterval(playhead)
                        chronometer.timerDidUpdate?(TimeInterval(playhead))
                    }
                }
                if !duration.isNaN {
                    self.endTimeLabel.text = AudioPlayManager.formatTimeFor(seconds: duration)
//                    if UserDefaults.standard.bool(forKey: "AutoplayEnable") && player.isPlaying && (duration >= 5.0 && duration <= 6.0) {
//                        PromptVManager.present(self, verifyTitle: currentAudio.Title, verifyMessage: AudioPlayManager.shared.audioList![AudioPlayManager.shared.nextIndex].Title, isAudioView: true, audioImage: AudioPlayManager.shared.audioList![AudioPlayManager.shared.nextIndex].ImageUrl)
//                    }
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
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        DispatchQueue.global(qos: .background).async {
            FavouriteAudioClient.add(FavouriteRequest(audio_story_id: audio_story_id)) { [self] status in
                if let st = status, st {
                    favButton.isSelected = true
                    AudioPlayManager.shared.currentAudio.Is_favorite = true
                    currentAudio.Is_favorite = true
                    if AudioPlayManager.shared.audioList != nil {
                        AudioPlayManager.shared.audioList![AudioPlayManager.shared.currentIndex].Is_favorite = true
                    }
                }
                completion(status)
            }
        }
    }
    
    // Remove from favourite
    private func removeFromFav(_ audio_story_id: Int, completion: @escaping(Bool?) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        DispatchQueue.global(qos: .background).async {
            FavouriteAudioClient.remove(FavouriteRequest(audio_story_id: audio_story_id)) { [self] status in
                if let st = status, st {
                    favButton.isSelected = false
                    AudioPlayManager.shared.currentAudio.Is_favorite = false
                    currentAudio.Is_favorite = false
                    if AudioPlayManager.shared.audioList != nil {
                        AudioPlayManager.shared.audioList![AudioPlayManager.shared.currentIndex].Is_favorite = false
                    }
                } else {
                    favButton.isSelected = true
                }
                completion(status)
            }
        }
    }
    
    func getAudios(_ storyIdCurrent: Int = -1) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            //completionHandler?()
            return
        }
        Core.ShowProgress(self, detailLbl: "")
//        AudioClient.getAudios(AudioRequest(page: "all", limit: 20)) { [self] response in
        AudioClient.getAudioById(storyIdCurrent) { [self] response in
            if let data = response, data.count > 0 {
                myAudioList = data
                AudioPlayManager.shared.audioList = myAudioList
                if let currAudioIdx = myAudioList.firstIndex(where: { $0.Id == storyIdCurrent }) {
                    currentAudioIndex = currAudioIdx
                } else {
                    currentAudioIndex = 0
                }
                AudioPlayManager.shared.setAudioIndex(currentAudioIndex, isNext: false)
                if myAudioList.count > 0 {
                    currentAudio = myAudioList[currentAudioIndex]
                }
                AudioPlayManager.shared.audioHistoryId = -1
                // Configure audio data
                setupAudioDataPlay(isPlaying)
            } else {
                Toast.show("No Audio Found!")
            }
            Core.HideProgress(self)
        }
    }
}

// MARK: - PromptViewDelegate -
extension NowPlayViewController: PromptViewDelegate {
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
        switch tag {
        case 0:
            //0 - Add to fav
//            if self.favButton.isSelected {
//                self.removeFromFav(currentAudio.Id) { status in }
//            } else {
//                self.addToFav(currentAudio.Id) { status in }
//            }
            break
        case 1, 3:
            //1 - Once more //3 - Close mini player //4 - Share audio
            DispatchQueue.main.async { [self] in
                if myAudioList.count > currentAudioIndex {
                    currentAudio = AudioPlayManager.shared.currentAudio
                    if currentAudioIndex >= 0 {
                        myAudioList[currentAudioIndex].Is_favorite = currentAudio.Is_favorite
                    }
                }
                favButton.isSelected = AudioPlayManager.shared.currentAudio.Is_favorite
                if let player = AudioPlayManager.shared.playerAV {
                    player.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: 1000))
                    AudioPlayManager.shared.playPauseAudioOnly(false, addToHistory: tag != 1)
                }
                self.visualizationWave.stop()
                self.visualizationWave.playChronometer = nil
                
                self.existingAudio = true
                if tag == 1 {
                    AudioPlayManager.shared.audioHistoryId = -1
                    currentPlayDuration = 0
                }
                self.setupAudioDataPlay(tag == 1)
//                if tag == 4 {
//                    AudioPlayManager.shareAudio(self)
//                }
            }
            break
        default:
            //2 - play next song
            DispatchQueue.main.async { [self] in
                currentAudio = AudioPlayManager.shared.currentAudio
                if myAudioList.count > 0 {
                    myAudioList[currentAudioIndex].Is_favorite = currentAudio.Is_favorite
                } else if let audioList = AudioPlayManager.shared.audioList, audioList.count > 0 {
                    AudioPlayManager.shared.audioList![AudioPlayManager.shared.currentIndex].Is_favorite = currentAudio.Is_favorite
                }
                favButton.isSelected = AudioPlayManager.shared.currentAudio.Is_favorite
                nextPrevPlay()
            }
            break
        }
    }
}

// MARK: - AudioListViewDelegate -
extension NowPlayViewController: AudioListViewDelegate {
    func changeIntoPlayingAudio(_ currentAudio: Audio) {
        self.currentAudio = currentAudio
        self.setAudioData()
        if AudioPlayManager.shared.currentAudio.Id == currentAudio.Id, let player = AudioPlayManager.shared.playerAV, player.isPlaying {
            self.existingAudio = true
            self.setupExistingAudio(true)
        } else if AudioPlayManager.shared.currentAudio.Id != currentAudio.Id {
            AudioPlayManager.shared.audioList = myAudioList
            AudioPlayManager.shared.setAudioIndex(currentAudioIndex, isNext: false)
            if let audList = AudioPlayManager.shared.audioList, AudioPlayManager.shared.currentIndex >= 0 {
                self.existingAudio = false
                self.currentAudio = audList[AudioPlayManager.shared.currentIndex]
                // Configure audio data
                setupAudioDataPlay(false)
            } else {
                Toast.show("Selected Audio not found!")
            }
        }
    }
}
