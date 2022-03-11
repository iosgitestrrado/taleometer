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
    
    // Get non stop audio
    private func getAudioList() {
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
                Snackbar.showErrorMessage("Audio not found!")
            }
            Core.HideProgress(self)
        })
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
            playPauseAudio(false)
            visualizationWave.stop()
            self.nextPrevPlay()
            break
        default:
            //Favourite
            sender.isSelected = !sender.isSelected
            break
        }
    }
    
    // MARK: Set audio data
    private func setupAudioData(_ playNow: Bool) {
        //guard let url = Bundle.main.url(forResource: "file_example_MP3_5MG", withExtension: "mp3") else { return }
        AudioPlayManager.shared.isNonStop = true
        
        self.audioTitle.text = audio.Title
        if let story = audio.Story {
            self.storyLabel.setTitle("Story: \(story.Name)", for: .normal)
        }
        if let plot = audio.Plot {
            self.plotLabel.setTitle("Plot: \(plot.Name)", for: .normal)
        }
        if let narration = audio.Story {
            self.narrotionLabel.setTitle("Narration: \(narration.Name)", for: .normal)
        }
        
        guard let url = URL(string: audio.File) else { return }
        stramingAudio(url, playNow: playNow)
    }
    
    // MARK: - Streaming audio file -
    func stramingAudio(_ audioUrl: URL, playNow: Bool) {
        Core.ShowProgress(self, detailLbl: "Streaming Audio...")
        // then lets create your document folder url
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        // lets create your destination file url
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)

        // to check if it exists before downloading it
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            audioURL = destinationUrl
            configureAudio(playNow)
        } else {
            // you can use NSURLSession.sharedSession to download the data asynchronously
            URLSession.shared.downloadTask(with: audioUrl, completionHandler: { [self] (location, response, error) -> Void in
                guard let location = location, error == nil else { return }
                do {
                    // after downloading your file you need to move it to your destination url
                    try FileManager.default.moveItem(at: location, to: destinationUrl)
                    audioURL = destinationUrl
                    configureAudio(playNow)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }).resume()
        }
    }

    // MARK: Set audio wave meter
    private func configureAudio(_ playNow: Bool) {
        Core.HideProgress(self)
        AudioPlayManager.shared.isNonStop = true
        //guard let url = Bundle.main.url(forResource: "file_example_MP3_5MG", withExtension: "mp3") else { return }
        guard let url = audioURL else { return }
        
        // Reset wave
        DispatchQueue.main.async {
            self.visualizationWave.reset()
        }
       
        // Check existing audio play and get player
        if existingAudio, let playerk = AudioPlayManager.shared.playerAV {
            player = playerk
            
            // Miniplayer active
            AudioPlayManager.shared.isMiniPlayerActive = true
            
            // Set waveform count
            waveFormcount = AudioPlayManager.shared.audioMetering.count
            
            // Set merering level of wave
            visualizationWave.meteringLevels = AudioPlayManager.shared.audioMetering
            
            DispatchQueue.main.async { [self] in
                // Update time duration in label
                self.visualizationWave.setNeedsDisplay()
                self.udpateTime()
                
                // Get audio duration and set in private variable
                if let duration = player.currentItem?.asset.duration {
                    totalTimeDuration = Float(CMTimeGetSeconds(duration))
                    if player.isPlaying {
                        visualizationWave.play(for: TimeInterval(totalTimeDuration))
                    }
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
                }
            }
        } else {
            // Configure new audio in audio player manager
//            AudioPlayManager.shared.configAudio(url)
            
            // Get audio play for use this class
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [self] in
                if let playerk = AudioPlayManager.shared.playerAV {
                    self.player = playerk
                }
                self.playButton.isSelected = false
            }

            // Show loading
            Core.ShowProgress(self, detailLbl: "Getting audio waves...")
            
            // Get audio meter from audio file
            AudioPlayManager.getAudioMeters(url, forChannel: 0) { [self] result in
                // Set waveform count
                waveFormcount = result.count
                visualizationWave.meteringLevels = result
                
                DispatchQueue.main.async {
                    // Update time duration in label
                    visualizationWave.setNeedsDisplay()
                    if let duration = player.currentItem?.asset.duration {
                        totalTimeDuration = Float(CMTimeGetSeconds(duration))
                        if !playNow {
                            if self.visualizationWave.playChronometer == nil {
                                visualizationWave.setplayChronometer(for: TimeInterval(totalTimeDuration))
                            }
//                            visualizationWave.play(for: TimeInterval(totalTimeDuration))
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [self] in
//                                visualizationWave.pause()
//                            }
                            udpateTime()
                        } else {
                            self.visualizationWave.playChronometer = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [self] in
                                if let playerk = AudioPlayManager.shared.playerAV {
                                    self.player = playerk
                                }
                            }
                            self.playPauseAudio(true)
                        }
                    }
                }
                // Hide loading
                Core.HideProgress(self)
            }            
        }
        // Pan gesture for scrubbing support.
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGestureRecognizer.cancelsTouchesInView = false
        visualizationWave.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func nextPrevPlay(_ isNext: Bool = true) {
        if let audioUrl = URL(string: AudioPlayManager.shared.audioList![isNext ? AudioPlayManager.shared.nextAudio : AudioPlayManager.shared.prevAudio].File) {
            let fileName = NSString(string: audioUrl.lastPathComponent)
            if !supportedAudioExtenstion.contains(fileName.pathExtension.lowercased()) {
                Snackbar.showErrorMessage("Audio File \"\(fileName.pathExtension)\" is not supported!")
                return
            }
        }
        let currentAudio = isNext ? AudioPlayManager.shared.nextAudio : AudioPlayManager.shared.prevAudio
        guard let audioList = AudioPlayManager.shared.audioList else {
            Snackbar.showAlertMessage("No Next audio found")
            return
        }
        AudioPlayManager.shared.currentAudio = currentAudio
        AudioPlayManager.shared.nextAudio = audioList.count - 1 > currentAudio ? currentAudio + 1 : 0
        AudioPlayManager.shared.prevAudio = currentAudio > 0 ? currentAudio - 1 : audioList.count - 1
        audio = audioList[currentAudio]
        
        // Configure audio data
        setupAudioData(true)
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
                PromptVManager.present(self, verifyTitle: audio.Title, verifyMessage: AudioPlayManager.shared.audioList![AudioPlayManager.shared.nextAudio].Title, isAudioView: true, audioImage: AudioPlayManager.shared.audioList![AudioPlayManager.shared.nextAudio].Image)
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
