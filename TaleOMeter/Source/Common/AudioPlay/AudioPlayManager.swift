//
//  AudioPlayManager.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit
import AVFoundation

class AudioPlayManager: NSObject {
    // MARK: - Static Properties -
    static let shared = AudioPlayManager()
    static let playImageName = "play"
    static let pauseImageName = "pause"
    static let playMiniImgName = "play.fill"
    static let pauseMiniImgName = "pause.fill"
    static let miniViewTag = 99999995

    // MARK: - Public Properties -
    public var playerAV: AVPlayer?
    public var isMiniPlayerActive = false
    public var waveFormcount = 0
    public var audioMetering = [Float]()
    
    // MARK: - Private Properties -
    private var audioTimer = Timer()
    private var currVController = UIViewController()
    private var bottomConstraint = NSLayoutConstraint()
    private var miniVController = MiniAudioViewController()

    public func configAudio(_ url: URL) {
        do {
            try
            AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            let playerItem = AVPlayerItem(url: url)
            playerAV = AVPlayer(playerItem: playerItem)
            isMiniPlayerActive = true
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @objc func itemDidFinishPlaying(notification: NSNotification) {
        audioTimer.invalidate()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FinishedPlaying"), object: nil)
    }
    
    public func addMiniPlayer(_ controller: UIViewController, bottomConstraint: NSLayoutConstraint) {
        //currVController.view.viewWithTag(AudioPlayManager.miniViewTag)?.removeFromSuperview()
        miniVController.view.removeFromSuperview()
        miniVController = UIStoryboard.init(name: Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "MiniAudioViewController") as! MiniAudioViewController
        miniVController.view.frame = CGRect.init(x: 0, y: UIScreen.main.bounds.size.height - 80.0, width: UIScreen.main.bounds.size.width, height: 60.0)
        if (FooterManager.shared.isActive) {
            if let footerView = controller.view.viewWithTag(FooterManager.viewTag) {
                footerView.removeFromSuperview()
                miniVController.view.frame = CGRect.init(x: 0, y: footerView.frame.origin.y - 60.0, width: UIScreen.main.bounds.size.width, height: (UIScreen.main.bounds.size.height - footerView.frame.origin.y) + 60.0)
                footerView.frame.origin.y = 60.0
                miniVController.view.addSubview(footerView)
            }
        }
        
        //miniVContainer.songImage
        miniVController.songTitle.text = "Tracts To Relax"
        udpateMiniPlayerTime()
        
        if let player = playerAV, player.isPlaying {
            miniVController.playButton.setImage(UIImage(systemName: AudioPlayManager.pauseMiniImgName), for: .normal)
            audioTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(AudioPlayManager.udpateMiniPlayerTime), userInfo: nil, repeats: true)
            RunLoop.main.add(self.audioTimer, forMode: .default)
            audioTimer.fire()
        } else {
            miniVController.playButton.setImage(UIImage(systemName: AudioPlayManager.playMiniImgName), for: .normal)
        }
        miniVController.playButton.addTarget(self, action: #selector(tapOnPlayMini(_:)), for: .touchUpInside)
        miniVController.closeButton.addTarget(self, action: #selector(tapOnCloseMini(_:)), for: .touchUpInside)
        miniVController.fullViewButton.addTarget(self, action: #selector(tapOnMiniPlayer(_:)), for: .touchUpInside)
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        miniVController.progressBar.tag = 9995555
        miniVController.progressBar.addGestureRecognizer(tapRecognizer)
        
        miniVController.view.tag = AudioPlayManager.miniViewTag
        bottomConstraint.constant = UIScreen.main.bounds.size.height - miniVController.view.frame.origin.y
        if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first {
            bottomConstraint.constant = UIScreen.main.bounds.size.height - miniVController.view.frame.origin.y - window.safeAreaInsets.bottom
        }
        controller.view.addSubview(miniVController.view)
        self.bottomConstraint = bottomConstraint
        currVController = controller
    }
    
    @objc private func udpateMiniPlayerTime() {
        if let player = playerAV, let currentItem = player.currentItem {
            // Get the current time in seconds
            let playhead = currentItem.currentTime().seconds
            let duration = currentItem.duration.seconds - currentItem.currentTime().seconds
            // Format seconds for human readable string
            if !playhead.isNaN {
                if playhead > 0 {
                    miniVController.startTimeLabel.text = AudioPlayManager.formatTimeFor(seconds: playhead + 1)
                } else {
                    miniVController.startTimeLabel.text = AudioPlayManager.formatTimeFor(seconds: playhead)
                }
            }
            if !duration.isNaN {
                miniVController.endTimeLabel.text = AudioPlayManager.formatTimeFor(seconds: duration)
            }
            if !playhead.isNaN && !currentItem.duration.seconds.isNaN{
                miniVController.progressBar.progress = Float(playhead / currentItem.duration.seconds)
            }
        }
    }
    
    public func removeMiniPlayer() {
        bottomConstraint.constant = 0
        if (FooterManager.shared.isActive) {
            if let footerView = miniVController.view.viewWithTag(FooterManager.viewTag) {
                footerView.removeFromSuperview()
                footerView.frame.origin.y = currVController.view.frame.size.height - 80.0
                currVController.view.addSubview(footerView)
                bottomConstraint.constant = UIScreen.main.bounds.size.height -  footerView.frame.origin.y
                if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first {
                    bottomConstraint.constant = UIScreen.main.bounds.size.height -  footerView.frame.origin.y - window.safeAreaInsets.bottom
                }
            }
        }
        miniVController.view.removeFromSuperview()
        guard let player = AudioPlayManager.shared.playerAV else { return }
        if player.isPlaying {
            audioTimer.invalidate()
            player.pause()
        }
    }
    
    @objc func tapOnPlayMini(_ sender:UIButton) {
        guard let player = AudioPlayManager.shared.playerAV else { return }
        if player.isPlaying {
            player.pause()
            sender.setImage(UIImage(systemName: AudioPlayManager.playMiniImgName), for: .normal)
            audioTimer.invalidate()
        } else {
            player.play()
            sender.setImage(UIImage(systemName: AudioPlayManager.pauseMiniImgName), for: .normal)
            audioTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(AudioPlayManager.udpateMiniPlayerTime), userInfo: nil, repeats: true)
            RunLoop.main.add(self.audioTimer, forMode: .default)
            audioTimer.fire()
        }
    }
    
    @objc func tapOnCloseMini(_ sender:UIButton) {
        isMiniPlayerActive = false
        removeMiniPlayer()
    }
    
    @objc func tapOnMiniPlayer(_ sender: UIButton) {
        let nowPlayingView = UIStoryboard.init(name: Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "NowPlayViewController") as! NowPlayViewController
        nowPlayingView.existingAudio = true
        currVController.navigationController?.pushViewController(nowPlayingView, animated: true)
    }
    
    // MARK: Convert seconds to current time for playing audio
    static func getHoursMinutesSecondsFrom(seconds: Double) -> (hours: Int, minutes: Int, seconds: Int) {
        let secs = Int(seconds)
        let hours = secs / 3600
        let minutes = (secs % 3600) / 60
        let seconds = (secs % 3600) % 60
        return (hours, minutes, seconds)
    }
    
    static func formatTimeFor(seconds: Double) -> String {
        let result = getHoursMinutesSecondsFrom(seconds: seconds)
        let hoursString = "\(result.hours)"
        var minutesString = "\(result.minutes)"
        if minutesString.utf8.count == 1 {
            minutesString = "0\(result.minutes)"
        }
        var secondsString = "\(result.seconds)"
        if secondsString.utf8.count == 1 {
            secondsString = "0\(result.seconds)"
        }
        var time = "\(hoursString):"
        if result.hours >= 1 {
            time.append("\(minutesString):\(secondsString)")
        }
        else {
            time = "\(minutesString):\(secondsString)"
        }
        return time
    }
    
    /*
     *  Calculate audio metering
     *
     */
    static func getAudioMeters(_ audioFileURL: URL, forChannel channelNumber: Int, completionHandler: @escaping(_ success: [Float]) -> ()) {
        let audioFile = try! AVAudioFile(forReading: audioFileURL)
        let audioFilePFormat = audioFile.processingFormat
        let audioFileLength = audioFile.length
        
        //Set the size of frames to read from the audio file, you can adjust this to your liking
        let frameSizeToRead = Int(audioFilePFormat.sampleRate/20)
        
        //This is to how many frames/portions we're going to divide the audio file
        let numberOfFrames = Int(audioFileLength)/frameSizeToRead
        
        //Create a pcm buffer the size of a frame
        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFilePFormat, frameCapacity: AVAudioFrameCount(frameSizeToRead)) else {
            fatalError("Couldn't create the audio buffer")
        }
        
        //Do the calculations in a background thread, if you don't want to block the main thread for larger audio files
        DispatchQueue.global(qos: .userInitiated).async {
            
            //This is the array to be returned
            var returnArray : [Float] = [Float]()
            
            //We're going to read the audio file, frame by frame
            for i in 0..<numberOfFrames {
                
                //Change the position from which we are reading the audio file, since each frame starts from a different position in the audio file
                audioFile.framePosition = AVAudioFramePosition(i * frameSizeToRead)
                
                //Read the frame from the audio file
                try! audioFile.read(into: audioBuffer, frameCount: AVAudioFrameCount(frameSizeToRead))
                
                //Get the data from the chosen channel
                let channelData = audioBuffer.floatChannelData![channelNumber]
                
                //This is the array of floats
                let arr = Array(UnsafeBufferPointer(start:channelData, count: frameSizeToRead))
                
                //Calculate the mean value of the absolute values
                let meanValue = arr.reduce(0, {$0 + abs($1)})/Float(arr.count)
                
                //Calculate the dB power (You can adjust this), if average is less than 0.000_000_01 we limit it to -160.0
                let dbPower: Float = meanValue > 0.000_000_01 ? 20 * log10(meanValue) : -160.0
                
                //append the db power in the current frame to the returnArray
                returnArray.append(Float((Double((dbPower * 1.5    ) / 100.0).roundToDecimal(2) * -1.0)))
            }
            AudioPlayManager.shared.audioMetering = returnArray
            completionHandler(returnArray)
        }
    }
}

// MARK: Check audio is playing
extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
