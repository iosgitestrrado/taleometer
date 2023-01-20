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
    private var isPlayingTap = false
    private var currentAudio = Audio()
    private var audioURL = URL(string: "")
    private var myAudioList = [Audio]()
    private var currentAudioIndex = -1
    private var audioPlayerFromSec = 0
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        AudioPlayManager.shared.audioHistoryId = -1
        getAudioList()
        
//        Pan gesture for scrubbing support.
//        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
//        panGestureRecognizer.cancelsTouchesInView = false
//        visualizationWave.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true, titleInLeft: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(remoteCommandHandler(_:)), name: remoteCommandName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishedPlaying(_:)), name: AudioPlayManager.finishNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        audioTimer.invalidate()
//        visualizationWave.pause()
    }
    
    // MARK: - When audio playing is finished -
    @objc private func itemDidFinishedPlaying(_ notification: Notification) {
//        self.playPauseAudio(false)
        self.nextPrevPlay(true, isPlayNow: true)

//        if /*!AudioPlayManager.shared.isTrivia,*/ AudioPlayManager.shared.isNonStop, UserDefaults.standard.bool(forKey: "AutoplayEnable"), let audioList = AudioPlayManager.shared.audioList, audioList.count > AudioPlayManager.shared.nextIndex  {
//            PromptVManager.present(self, verifyTitle: currentAudio.Title, verifyMessage: audioList[AudioPlayManager.shared.nextIndex].Title, isAudioView: true, audioImage: audioList[AudioPlayManager.shared.nextIndex].ImageUrl)
//        }
    }
    
    // Get non stop audio
    private func getAudioList() {
        if existingAudio {
            setupExistingAudio(isPlayingExisting)
            if let audList = AudioPlayManager.shared.audioList, AudioPlayManager.shared.currentIndex >= 0 {
                currentAudio = audList[AudioPlayManager.shared.currentIndex]
                setAudioData()
            }
        } else {
            if !Reachability.isConnectedToNetwork() {
                Core.noInternet(self)
                return
            }
            Core.ShowProgress(self, detailLbl: "")
            AudioClient.getNonstopAudio(AudioRequest(page: "all", limit: 30)) { [self] result, nonStopStatus in
                if let response = result, response.count > 0 {
                    AudioPlayManager.shared.audioList = response
                    myAudioList = response
                    currentAudioIndex = 0
                    if let nonStatus = nonStopStatus, nonStatus.Action.lowercased() == "pause" {
                        currentAudioIndex = myAudioList.firstIndex(where: { $0.Id == nonStatus.Audio_story_id }) ?? 0
                        self.audioPlayerFromSec = nonStatus.Time
                    }
                    AudioPlayManager.shared.setAudioIndex(currentAudioIndex ,isNext: false)
                    currentAudio = response[AudioPlayManager.shared.currentIndex]
                    setupAudioDataPlay(true)
                } else {
                    Core.HideProgress(self)
                    self.navigationController?.popViewController(animated: true)
                }
            }
//            AudioClient.get(AudioRequest(page: "all", limit: 10), isNonStop: true, completion: { [self] result in
//                if let response = result {
//                    AudioPlayManager.shared.audioList = response
//                    myAudioList = response
//                    currentAudioIndex = 0
//                    AudioPlayManager.shared.setAudioIndex(0 ,isNext: false)
//                    currentAudio = response[AudioPlayManager.shared.currentIndex]
//                    setupAudioDataPlay(true)
//                }
//                Core.HideProgress(self)
//            })
        }
    }
    
    // MARK: Set audio data only
    private func setAudioData() {
        self.audioTitle.text = currentAudio.Title
        self.storyLabel.isHidden = currentAudio.IsLinkedAudio
        self.plotLabel.isHidden = currentAudio.IsLinkedAudio
        self.narrotionLabel.isHidden = currentAudio.IsLinkedAudio
        self.storyLabel.setTitle("Story: \(currentAudio.Story.Name)", for: .normal)
        self.plotLabel.setTitle("Plot: \(currentAudio.Plot.Name)", for: .normal)
        self.narrotionLabel.setTitle("Narration: \(currentAudio.Narration.Name)", for: .normal)
        self.favButton.isSelected = currentAudio.Is_favorite
        self.favButton.isHidden = currentAudio.IsLinkedAudio
    }
    
    // MARK: Set audio data and play
    private func setupAudioDataPlay(_ playNow: Bool) {
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
            //Core.ShowProgress(self, detailLbl: "Streaming Audio")
            
            // Initialize audio play in audio player manager
            AudioPlayManager.shared.initPlayerManager(isNonStop: true) { result in
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
                if audioPlayerFromSec > 0, let chronometer = self.visualizationWave.playChronometer {
                    self.seekAudioTo(Double(audioPlayerFromSec))
                    chronometer.timerCurrentValue = TimeInterval(audioPlayerFromSec)
                    chronometer.timerDidUpdate?(TimeInterval(audioPlayerFromSec))
                }
                audioPlayerFromSec = 0
            }
            if !playNow {
                udpateTime()
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
                
                // Get audio duration and set in private variable
                if let duration = player.currentItem?.asset.duration {
                    // Totalvidio duration
                    totalTimeDuration = Float(CMTimeGetSeconds(duration))
                    
                    // Setup chrono meter befor playing video
                    if playNow {
                        // Visulization chrono set to null
                        self.visualizationWave.playChronometer = nil
                    } else if self.visualizationWave.playChronometer == nil {
                        // Set audio start end label
                        self.udpateTime()
                    }
                                    
                    // Set up visulation wave as per audio duration
                    visualizationWave.setplayChronometer(for: TimeInterval(totalTimeDuration))
                    
                    if audioPlayerFromSec > 0 {
                        self.seekAudioTo(Double(audioPlayerFromSec))
                        if let chronometer = self.visualizationWave.playChronometer {
                            chronometer.timerCurrentValue = TimeInterval(audioPlayerFromSec)
                            chronometer.timerDidUpdate?(TimeInterval(audioPlayerFromSec))
                        }
                    }
                    audioPlayerFromSec = 0
                    // Play or pause current audio
                    self.playPauseAudio(playNow)
                }
            }
        }
    }
    
    //MARK: - Call funcation when audio controller press in background
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
        }
        
        
//        if let isNext = notification.userInfo?["isNext"] as? Bool {
//            // Play next or previouse audio
//            nextPrevPlay(isNext ,isPlayNow: true)
//        }
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
    
    private func seekAudioTo(_ newTime: Double) {
        if let player = AudioPlayManager.shared.playerAV {
            guard let duration = player.currentItem?.duration else {
                    return
            }
            if newTime < CMTimeGetSeconds(duration) {
                let time2: CMTime = CMTimeMake(value: Int64(newTime) * 1000, timescale: 1000)
                player.seek(to: time2)
                setTime(newTime)
            } else {
                let time2: CMTime = CMTimeMake(value: Int64(CMTimeGetSeconds(duration)) * 1000, timescale: 1000)
                player.seek(to: time2)
                setTime(newTime)
            }
        }
    }
    
    // MARK: - Set start and end time
    private func setTime(_ currentTime: TimeInterval) {
        let playhead = currentTime
        let duration = TimeInterval(totalTimeDuration) - currentTime
        
        if !playhead.isNaN && !duration.isNaN {
            self.audioTime.text = "\(AudioPlayManager.formatTimeFor(seconds: playhead + 1)) \\ \(AudioPlayManager.formatTimeFor(seconds: duration))"
        }
        if let chronometer = self.visualizationWave.playChronometer {
            chronometer.timerCurrentValue = currentTime
            chronometer.timerDidUpdate?(currentTime)
        }
    }
    
    // MARK: - Tap On Non stop
    @IBAction func tapOnNonStop(_ sender: UIButton) {
        UIView.transition(with: sender as UIView, duration: 0.75, options: .transitionCrossDissolve) {
            sender.isSelected = !sender.isSelected
        } completion: { [self] isDone in
//            if isPlaying {
            playPauseAudio(!sender.isSelected, action: "stop")
//            }
            AudioPlayManager.shared.isNonStop = !sender.isSelected
            AudioPlayManager.shared.isMiniPlayerActive = !sender.isSelected
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - SPN stands Story(0) Plot(1) and Narrotion(2)
    @IBAction func tapOnSPNButton(_ sender: UIButton) {
        let authorView = UIStoryboard(name: Constants.Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "AuthorViewController") as! AuthorViewController
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
    
    // MARK: - Play(0) Next(1) Favourite(2)
    @IBAction func tapOnAudioController(_ sender: UIButton) {
        if let player = AudioPlayManager.shared.playerAV {
            switch sender.tag {
            case 0:
                //Play
                self.playPauseAudio(!player.isPlaying)
                break
            case 1:
                //Next
                self.nextPrevPlay(true, isPlayNow: player.isPlaying)
                break
            default:
                //Favourite
                if sender.isSelected {
                    self.removeFromFav(currentAudio.Id) { status in }
                } else {
                    self.addToFav(currentAudio.Id) { status in }
                }
                break
            }
        }
    }
    
    // MARK: - Play next or previous audio
    private func nextPrevPlay(_ isNext: Bool = true, isPlayNow: Bool) {
        // Current player pause and visualization wave stop
//        visualizationWave.pause()
        
        // Setup audio index
        AudioPlayManager.shared.setAudioIndex(isNext: isNext)
        
        // No existing audio play
        self.existingAudio = false
        
        // Setup current audio variable
        self.currentAudio = AudioPlayManager.shared.currentAudio
        Core.ShowProgress(self, detailLbl: "")
        // Configure audio data
        setupAudioDataPlay(isPlayNow)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, touch.view == self.visualizationWave {
            if let player = AudioPlayManager.shared.playerAV {
                isPlayingTap = player.isPlaying
                if (isPlayingTap) {
                    player.pause()
                }
            }
        }
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
                if (isPlayingTap) {
                    player.play()
                }
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
    
    // MARK: - Handle audio play and pause
    private func playPauseAudio(_ playing: Bool, action: String = "pause") {
        //if let player = AudioPlayManager.shared.playerAV {
        AudioPlayManager.shared.playPauseAudioOnly(playing, action: action)
        DispatchQueue.main.async {
            self.playButton.isSelected = playing
        }
        
        isPlaying = playing
        if !playing {
            audioTimer.invalidate()
//            visualizationWave.pause()
            //NotificationCenter.default.post(name: Notification.Name(rawValue: "pauseAudio"), object: nil)
        } else {
            audioTimer = Timer(timeInterval: 0.25, target: self, selector: #selector(NonStopViewController.udpateTime), userInfo: nil, repeats: true)
            RunLoop.main.add(self.audioTimer, forMode: .default)
            audioTimer.fire()
            //NotificationCenter.default.post(name: Notification.Name(rawValue: "playAudio"), object: nil)
//            visualizationWave.play(for: TimeInterval(totalTimeDuration))
        }
       // }
    }
    
    // MARK: - Set start and end time
    @objc func udpateTime() {
        if let player = AudioPlayManager.shared.playerAV, let currentItem = player.currentItem {
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
                if let chronometer = self.visualizationWave.playChronometer {
                    chronometer.timerCurrentValue = TimeInterval(playhead)
                    chronometer.timerDidUpdate?(TimeInterval(playhead))
                }
            }
//            if UserDefaults.standard.bool(forKey: "AutoplayEnable") && !duration.isNaN && (duration >= 5.0 && duration <= 6.0) {
//                PromptVManager.present(self, verifyTitle: currentAudio.Title, verifyMessage: AudioPlayManager.shared.audioList![AudioPlayManager.shared.nextIndex].Title, isAudioView: true, audioImage: AudioPlayManager.shared.audioList![AudioPlayManager.shared.nextIndex].ImageUrl)
//            }
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
            Core.noInternet(self)
            return
        }
        DispatchQueue.global(qos: .background).async {
            FavouriteAudioClient.add(FavouriteRequest(audio_story_id: audio_story_id)) { [self] status in
                if let st = status, st {
                    favButton.isSelected = !favButton.isSelected
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
                    favButton.isSelected = !favButton.isSelected
                    AudioPlayManager.shared.currentAudio.Is_favorite = false
                    currentAudio.Is_favorite = false
                    if AudioPlayManager.shared.audioList != nil {
                        AudioPlayManager.shared.audioList![AudioPlayManager.shared.currentIndex].Is_favorite = false
                    }
                }
                completion(status)
            }
        }
    }
}


// MARK: - PromptViewDelegate -
extension NonStopViewController: PromptViewDelegate {
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
                currentAudio = AudioPlayManager.shared.currentAudio
                favButton.isSelected = AudioPlayManager.shared.currentAudio.Is_favorite
                myAudioList[currentAudioIndex].Is_favorite = currentAudio.Is_favorite
                if let player = AudioPlayManager.shared.playerAV {
                    player.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: 1000))
                    AudioPlayManager.shared.playPauseAudioOnly(false, addToHistory: tag != 1)
                }
                self.visualizationWave.stop()
                self.existingAudio = true
                if tag == 1 {
                    AudioPlayManager.shared.audioHistoryId = -1
                }
                self.setupAudioDataPlay(tag == 1)
            }
            break
        default:
            //2 - play next song
            DispatchQueue.main.async { [self] in
                currentAudio = AudioPlayManager.shared.currentAudio
                favButton.isSelected = AudioPlayManager.shared.currentAudio.Is_favorite
                myAudioList[currentAudioIndex].Is_favorite = currentAudio.Is_favorite
                nextPrevPlay(isPlayNow: true)
            }
            break
        }
    }
}

// MARK: - AudioListViewDelegate -
extension NonStopViewController: AudioListViewDelegate {
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
