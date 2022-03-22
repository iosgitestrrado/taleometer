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
    @IBOutlet weak var favButton: UIButton!

    // MARK: - Public Properties -
    var existingAudio = false
    var isPlaying = false
    var waveFormcount = 0
    var myAudioList = [Audio]()
    var currentAudioIndex = -1

    // MARK: - Private Properties -
    private var totalTimeDuration: Float = 0.0
    private var audioTimer = Timer()
    private var isPlayingTap = false
    private var currentAudio = Audio()
    private var audioURL = URL(string: "")

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.audioImageView.cornerRadius = self.audioImageView.frame.size.height / 2.0
        
        if let audList = AudioPlayManager.shared.audioList, AudioPlayManager.shared.currentAudio >= 0 {
            currentAudio = audList[AudioPlayManager.shared.currentAudio]
            // Configure audio data
            setupAudioDataPlay(isPlaying)
        } else {
            Toast.show("Selected Audio not found!")
        }
        // Set notification center for audio playing completed
        NotificationCenter.default.addObserver(self, selector: #selector(remoteCommandHandler(_:)), name: remoteCommandName, object: nil)
        
        // Pan gesture for scrubbing support.
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGestureRecognizer.cancelsTouchesInView = false
        visualizationWave.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true, titleInLeft: false)
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.audioImageView.cornerRadius = self.audioImageView.frame.size.height / 2.0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        audioTimer.invalidate()
        visualizationWave.pause()
    }
    
    //MARK: - Call funcation when audio controller press in background
    @objc private func remoteCommandHandler(_ notification: Notification) {
        if (notification.userInfo?["isPlaying"] as? Bool) != nil {
            self.playPauseWave()
        } else if let isNext = notification.userInfo?["isNext"] as? Bool {
            seekAudio(isNext)
        }
    }
    
    // MARK: Set audio data only
    private func setAudioData() {
        self.imageView.image = currentAudio.Image
        self.titleLabel.text = currentAudio.Title
        self.storyButton.setTitle("Story: \(currentAudio.Story.Name)", for: .normal)
        self.plotButton.setTitle("Plot: \(currentAudio.Plot.Name)", for: .normal)
        self.narrotionButton.setTitle("Narration: \(currentAudio.Narration.Name)", for: .normal)
        
        self.cuncurrentUserLbl.text = "Concurrent Users: \(currentAudio.Views_count.formatPoints())"
        self.favButton.isSelected = currentAudio.Is_favorite
    }
    
    // MARK: Set audio data and play audio
    private func setupAudioDataPlay(_ playNow: Bool) {
        //guard let url = Bundle.main.url(forResource: "file_example_MP3_5MG", withExtesnsion: "mp3") else { return }
        AudioPlayManager.shared.isNonStop = false
        setAudioData()
        if existingAudio {
            setupExistingAudio(playNow)
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
                
                // Get audio duration and set in private variable
                if let duration = player.currentItem?.asset.duration {
                    // Totalvidio duration
                    totalTimeDuration = Float(CMTimeGetSeconds(duration))
                    
                    // Setup chrono meter befor playing video
                    if playNow {
                        self.visualizationWave.playChronometer = nil
                    } else if self.visualizationWave.playChronometer == nil {
                        self.udpateTime()
                        visualizationWave.setplayChronometer(for: TimeInterval(totalTimeDuration))
                    }
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
            self.currentAudio = AudioPlayManager.shared.audio
        
            // Configure audio data
            setupAudioDataPlay(player.isPlaying)
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
    
    private func playPauseWave() {
        if let player = AudioPlayManager.shared.playerAV {
            if !player.isPlaying {
                if audioTimer.isValid {
                    audioTimer.invalidate()
                }
                audioTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(NowPlayViewController.udpateTime), userInfo: nil, repeats: true)
                RunLoop.main.add(self.audioTimer, forMode: .default)
                audioTimer.fire()
                if let ch = visualizationWave.playChronometer, !ch.isPlaying {
                    visualizationWave.play(for: TimeInterval(totalTimeDuration))
                }
            } else {
                audioTimer.invalidate()
                visualizationWave.pause()
            }
            self.playButton.isSelected = !player.isPlaying
        }
    }
    
    // MARK: - Handle play pause audio
    private func playPauseAudio(_ playing: Bool) {
        if let player = AudioPlayManager.shared.playerAV {
            //print("Audio is playing: \(playing)")
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
                self.removeFromFav(currentAudio.Id) { status in
                    if let st = status, st {
                        sender.isSelected = !sender.isSelected
                    }
                }
            } else {
                self.addToFav(currentAudio.Id) { status in
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
    
    // MARK: - Update time as per playing audio
    @objc func udpateTime() {
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
                }
                if !duration.isNaN {
                    self.endTimeLabel.text = AudioPlayManager.formatTimeFor(seconds: duration)
                    if player.isPlaying && (duration >= 5.0 && duration <= 6.0) {
                        PromptVManager.present(self, verifyTitle: currentAudio.Title, verifyMessage: AudioPlayManager.shared.audioList![AudioPlayManager.shared.nextAudio].Title, image: nil, ansImage: nil, isAudioView: true, audioImage: AudioPlayManager.shared.audioList![AudioPlayManager.shared.nextAudio].Image)
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
extension NowPlayViewController: PromptViewDelegate {
    func didActionOnPromptButton(_ tag: Int) {
        switch tag {
        case 0:
            //0 - Add to fav
            self.addToFav(currentAudio.Id) { status in }
            break
        case 1, 3:
            //1 - Once more //3 - Close mini player
            DispatchQueue.main.async {
                if let player = AudioPlayManager.shared.playerAV {
                    player.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: 1000))
                    player.pause()
                }
                self.visualizationWave.stop()
                self.visualizationWave.playChronometer = nil
                
                self.existingAudio = true
                self.setupAudioDataPlay(tag == 1)
            }
            break
        default:
            //2 - play next song
            nextPrevPlay()
            break
        }
    }
}

// MARK: - AudioListViewDelegate -
extension NowPlayViewController: AudioListViewDelegate {
    func changeIntoPlayingAudio(_ currentAudio: Audio) {
        self.currentAudio = currentAudio
        self.setAudioData()
        if AudioPlayManager.shared.audio.Id == currentAudio.Id, let player = AudioPlayManager.shared.playerAV, player.isPlaying {
            self.existingAudio = true
            self.setupExistingAudio(true)
        } else if AudioPlayManager.shared.audio.Id != currentAudio.Id {
            AudioPlayManager.shared.audioList = myAudioList
            AudioPlayManager.shared.setAudioIndex(currentAudioIndex, isNext: false)
            if let audList = AudioPlayManager.shared.audioList, AudioPlayManager.shared.currentAudio >= 0 {
                self.existingAudio = false
                self.currentAudio = audList[AudioPlayManager.shared.currentAudio]
                // Configure audio data
                setupAudioDataPlay(false)
            } else {
                Toast.show("Selected Audio not found!")
            }
        }
    }
}
