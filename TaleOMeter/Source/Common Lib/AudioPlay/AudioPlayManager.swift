//
//  AudioPlayManager.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit
import AVFoundation
import MediaPlayer

class AudioPlayManager: NSObject {
    // MARK: - Static Properties -
    static let shared = AudioPlayManager()
    static let playImage = UIImage(named: "play")
    static let pauseImage = UIImage(named: "pause")
    static let playMiniImage = UIImage(systemName: "play.fill")
    static let pauseMiniImage = UIImage(systemName: "pause.fill")
    static let miniViewTag = 99999995

    // MARK: - Public Properties -
    public var playerAV: AVPlayer?
    public var isMiniPlayerActive = false
    public var isNonStop = false
    public var waveFormcount = 0
    public var audioMetering = [Float]()
    public var nowPlayingInfo = [String: Any]()

    // MARK: - Private Properties -
    private var audioTimer = Timer()
    private var currVController = UIViewController()
    private var bottomConstraint = NSLayoutConstraint()
    private var miniVController = MiniAudioViewController()

    
    // MARK: - Configure audio as per pass url -
    public func configAudio(_ url: URL) {
        /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
        let playerItem = AVPlayerItem(url: url)
        playerAV = AVPlayer(playerItem: playerItem)
        isMiniPlayerActive = true
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        setupRemoteTransportControls()
    }
    
    // MARK: - Set audio notification on mobile application -
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()

        setupNowPlaying()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if let playerAV = playerAV, !playerAV.isPlaying {
                playerAV.play()
                if let miniPlayBtn = miniVController.playButton {
                    miniPlayBtn.isSelected = !playerAV.isPlaying
                    audioTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(AudioPlayManager.udpateMiniPlayerTime), userInfo: nil, repeats: true)
                    RunLoop.main.add(self.audioTimer, forMode: .default)
                    audioTimer.fire()
                }
                NotificationCenter.default.post(name: remoteCommandName, object: nil, userInfo: ["isPlaying": true])
                return .success
            }
            return .commandFailed
        }

        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if let playerAV = playerAV, playerAV.isPlaying {
                NotificationCenter.default.post(name: remoteCommandName, object: nil, userInfo: ["isPlaying": false])
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Previous Command
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            if playerAV != nil {
                seekMiniPlayer(false)
                NotificationCenter.default.post(name: remoteCommandName, object: nil, userInfo: ["isNext": false])
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Next Command
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            if playerAV != nil {
                seekMiniPlayer(true)
                NotificationCenter.default.post(name: remoteCommandName, object: nil, userInfo: ["isNext": true])
                return .success
            }
            return .commandFailed
        }
    }
    
    // MARK: - Setup now playing for notification on mobile application -
    func setupNowPlaying() {
        // Define Now Playing Info
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()

        nowPlayingInfo[MPMediaItemPropertyTitle] = "Tracts To Relax"
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = "Jane Doe"
        nowPlayingInfo[MPMediaItemPropertyArtist] = "Story"

        if let image = UIImage(named: "logo") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
            }
        }
        if let playerAV = playerAV {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerAV.currentTime().seconds
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = Int((playerAV.currentItem?.asset.duration.seconds)!)
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = playerAV.rate
        }
        
        // Set the metadata
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    // MARK: - When audio completed call function -
    @objc func itemDidFinishPlaying(notification: NSNotification) {
        audioTimer.invalidate()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FinishedPlaying"), object: nil)
    }
    
    // MARK: - Add mini player to controller
    public func addMiniPlayer(_ controller: UIViewController, bottomConstraint: NSLayoutConstraint = NSLayoutConstraint()) {
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
            audioTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(AudioPlayManager.udpateMiniPlayerTime), userInfo: nil, repeats: true)
            RunLoop.main.add(self.audioTimer, forMode: .default)
            audioTimer.fire()
            miniVController.playButton.isSelected = false
        } else {
            miniVController.playButton.isSelected = true
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
            bottomConstraint.constant = UIScreen.main.bounds.size.height -  (miniVController.view.frame.origin.y + window.safeAreaInsets.bottom)
        }
        controller.view.addSubview(miniVController.view)
        self.bottomConstraint = bottomConstraint
        currVController = controller
    }
    
    // MARK: - Add mini player time and progress bar
    @objc func udpateMiniPlayerTime() {
        if let currentItem = playerAV?.currentItem, miniVController.startTimeLabel != nil {
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
            
            if !duration.isNaN && (duration >= 5.0 && duration <= 6.0) {
                PromptVManager.present(currVController, isAudioView: true)
            }
            
            miniVController.progressBar.setNeedsDisplay()
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playhead
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
    
    // MARK: - Forward and backward miniplayer for 10 seconds
    @objc private func seekMiniPlayer(_ forward: Bool) {
        if let player = playerAV {
            if forward {
                guard let duration  = player.currentItem?.duration else {
                    return
                }
                let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
                let newTime = playerCurrentTime + 10

                if newTime < CMTimeGetSeconds(duration) {
                    let time2: CMTime = CMTimeMake(value: Int64(newTime) * 1000, timescale: 1000)
                    player.seek(to: time2)
                } else {
                    let time2: CMTime = CMTimeMake(value: Int64(CMTimeGetSeconds(duration)) * 1000, timescale: 1000)
                    player.seek(to: time2)
                }
            } else {
                let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
                var newTime = playerCurrentTime - 10
                if newTime < 0 {
                    newTime = 0
                }
                let time2: CMTime = CMTimeMake(value: Int64(newTime) * 1000, timescale: 1000)
                player.seek(to: time2)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.udpateMiniPlayerTime()
        }
    }
    
    // MARK: - Remove mini player from view controller
    public func removeMiniPlayer() {
        bottomConstraint.constant = 0
        if (FooterManager.shared.isActive) {
            if let footerView = miniVController.view.viewWithTag(FooterManager.viewTag) {
                footerView.removeFromSuperview()
                footerView.frame.origin.y = currVController.view.frame.size.height - 80.0
                currVController.view.addSubview(footerView)
                bottomConstraint.constant = UIScreen.main.bounds.size.height -  footerView.frame.origin.y
                if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first {
                    bottomConstraint.constant = UIScreen.main.bounds.size.height -  (footerView.frame.origin.y + window.safeAreaInsets.bottom)
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
    
    // MARK: - Click on miniplayer play pause button
    @objc func tapOnPlayMini(_ sender: UIButton) {
        guard let player = AudioPlayManager.shared.playerAV else { return }
        miniVController.playButton.isSelected = player.isPlaying
        if player.isPlaying {
            player.pause()
            audioTimer.invalidate()
        } else {
            player.play()
            audioTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(AudioPlayManager.udpateMiniPlayerTime), userInfo: nil, repeats: true)
            RunLoop.main.add(self.audioTimer, forMode: .default)
            audioTimer.fire()
        }
    }
    
    // MARK: - Close miniplayer
    @objc func tapOnCloseMini(_ sender:UIButton) {
        isMiniPlayerActive = false
        removeMiniPlayer()
    }
    
    // MARK: - Click on miniplayer
    @objc func tapOnMiniPlayer(_ sender: UIButton) {
        if isNonStop {
            let nonStopViewView = UIStoryboard.init(name: Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "NonStopViewController") as! NonStopViewController
            nonStopViewView.existingAudio = true
            currVController.navigationController?.pushViewController(nonStopViewView, animated: true)
        } else {
            let nowPlayingView = UIStoryboard.init(name: Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "NowPlayViewController") as! NowPlayViewController
            nowPlayingView.existingAudio = true
            currVController.navigationController?.pushViewController(nowPlayingView, animated: true)
        }
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
