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
    private var totalTimeDuration: Float = 0.0
    private var audioTimer = Timer()
    private var isPlayingTap = false
    private var player = AVPlayer()
    private var audio = Audio()
    private var audioURL = URL(string: "")

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
        if let story = audio.Story {
            self.storyButton.setTitle("Story: \(story.Name)", for: .normal)
        }
        if let plot = audio.Plot {
            self.storyButton.setTitle("Plot: \(plot.Name)", for: .normal)
        }
        if let narration = audio.Story {
            self.storyButton.setTitle("Narration: \(narration.Name)", for: .normal)
        }
        
        self.cuncurrentUserLbl.text = "Concurrent Users: \(audio.Views_count.formatPoints())"
        
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
    
    //  MARK: - Set up audio wave and play
    func configureAudio(_ playNow: Bool) {
        // Hide loading
        Core.HideProgress(self)
        guard let url = audioURL else { return }
        
        // Reset wave
        visualizationWave.reset()
        // Check existing audio play and get player
        if existingAudio, let playerk = AudioPlayManager.shared.playerAV {
            player = playerk
            
            // Miniplayer active
            AudioPlayManager.shared.isMiniPlayerActive = true
            
            // Set waveform count
            waveFormcount = AudioPlayManager.shared.audioMetering.count
            
            // Set merering level of wave
            visualizationWave.meteringLevels = AudioPlayManager.shared.audioMetering
            
            // Update time duration in label
            DispatchQueue.main.async { [self] in
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
                
                // Update play button image as per audio playing and enable timer
                self.playButton.isSelected = player.isPlaying
                if player.isPlaying {
                    audioTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(NowPlayViewController.udpateTime), userInfo: nil, repeats: true)
                    RunLoop.main.add(self.audioTimer, forMode: .default)
                    audioTimer.fire()
                } else {
    //                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [self] in
    //                    visualizationWave.pause()
    //                }
                }
            }
        } else {
            // Configure new audio in audio player manager
            AudioPlayManager.shared.configAudio(url)
            
            // Get audio play for use this class
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [self] in
                if let playerk = AudioPlayManager.shared.playerAV {
                    self.player = playerk
                }
            }
            self.playButton.isSelected = false
            
            // Show loading
            Core.ShowProgress(self, detailLbl: "Getting audio waves...")
            // Get audio meter from audio file
            AudioPlayManager.getAudioMeters(url, forChannel: 0) { [self] result in
                // Set waveform count
                waveFormcount = result.count
                visualizationWave.meteringLevels = result
                
                // Update time duration in label
                DispatchQueue.main.async {
                    visualizationWave.setNeedsDisplay()
                    if let chronometer = self.visualizationWave.playChronometer {
                        chronometer.timerCurrentValue = TimeInterval(0)
                        chronometer.timerDidUpdate?(TimeInterval(0))
                    }
                    // Get audio duration and set in private variable
                    if let duration = player.currentItem?.asset.duration {
                        totalTimeDuration = Float(CMTimeGetSeconds(duration))
                        if !playNow {
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
            sender.isSelected = !sender.isSelected
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
        self.playPauseAudio(false)
        existingAudio = false
        configureAudio(false)
        if let chronometer = self.visualizationWave.playChronometer {
            chronometer.timerCurrentValue = TimeInterval(0)
            chronometer.timerDidUpdate?(TimeInterval(0))
        }
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
                    if (duration >= 5.0 && duration <= 6.0) {
                        PromptVManager.present(self, verifyTitle: audio.Title, verifyMessage: AudioPlayManager.shared.audioList![AudioPlayManager.shared.nextAudio].Title, isAudioView: true, audioImage: AudioPlayManager.shared.audioList![AudioPlayManager.shared.nextAudio].Image)
                    }
                }
                AudioPlayManager.shared.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playhead
                MPNowPlayingInfoCenter.default().nowPlayingInfo = AudioPlayManager.shared.nowPlayingInfo
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
            playPauseAudio(false)
            existingAudio = false
            configureAudio(true)
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

