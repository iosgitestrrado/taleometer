//
//  AudioPlayManager.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//  Copyright © 2022 Durgesh. All rights reserved.
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
    var playerAV: AVPlayer?
    var isMiniPlayerActive = false
    var isNonStop = false
    var waveFormcount = 0
    var audioMetering = [Float]()
    var nowPlayingInfo = [String: Any]()
    var currentAudio = -1
    var nextAudio = -1
    var prevAudio = -1
    var audioList: [Audio]?
    var audioURL = URL(string: "")
    var audio = Audio()

    // MARK: - Private Properties -
    fileprivate var audioTimer = Timer()
    fileprivate var currVController = UIViewController()
    fileprivate var bottomConstraint = NSLayoutConstraint()
    fileprivate var miniVController = MiniAudioViewController()

    // MARK: - Configure audio as per pass url -
    public func initPlayerManager(_ playNow: Bool = false, isNonStop: Bool = false, getMeters: Bool = true, completionHandler: @escaping(_ success: [Float]) -> ()) {
        
        guard let audList = audioList else {
            Snackbar.showAlertMessage("No audio found!")
            return
        }
        self.isNonStop = isNonStop
        audio = audList[currentAudio]
        
        guard let url = URL(string: audio.File) else { return }
        stramingAudio(url, playNow: playNow, getMeters: getMeters) { result in
            completionHandler(result)
        }
    }
    
    // MARK: - Streaming audio file -
    private func stramingAudio(_ audioUrl: URL, playNow: Bool, getMeters: Bool, completionHandler: @escaping(_ success: [Float]) -> ()) {
        // then lets create your document folder url
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        // lets create your destination file url
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)

        // to check if it exists before downloading it
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            audioURL = destinationUrl
            configureAudio(playNow, getMeters: getMeters) { result in
                completionHandler(result)
            }
        } else {
            // you can use NSURLSession.sharedSession to download the data asynchronously
            URLSession.shared.downloadTask(with: audioUrl, completionHandler: { [self] (location, response, error) -> Void in
                guard let location = location, error == nil else { return }
                do {
                    // after downloading your file you need to move it to your destination url
                    try FileManager.default.moveItem(at: location, to: destinationUrl)
                    audioURL = destinationUrl
                    configureAudio(playNow, getMeters: getMeters) { result in
                        completionHandler(result)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }).resume()
        }
    }
    
    private func configureAudio(_ playNow: Bool, getMeters: Bool, completionHandler: @escaping(_ success: [Float]) -> ()) {
        
        // Check URL exists
        guard let url = audioURL else {
            Snackbar.showAlertMessage("No audio found!")
            return
        }
        
        // Initialize player with item additional url
        let playerItem = AVPlayerItem(url: url)
        
        // Inititialize Player
        playerAV = AVPlayer(playerItem: playerItem)
        
        // Enable Miniplayer now
        isMiniPlayerActive = true
        
        // Set notification for audio finish
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        // Set local notification data for audio
        setupRemoteTransportControls()
                
        if getMeters {
            // Get audio meter and seton the variable
            AudioPlayManager.getAudioMeters(url, forChannel: 0) { success in
                self.audioMetering = success
                completionHandler(success)
            }
        } else {
            completionHandler([Float]())
        }
    }
    
    // MARK: Play pause audio
    private func playPauseAudio(_ isPlay: Bool) {
        guard let player = playerAV else { return }
        if let miniPlayBtn = miniVController.playButton {
            miniPlayBtn.isSelected = !isPlay
        }
        if isPlay {
            if !player.isPlaying {
                player.play()
            }
            
            if audioTimer.isValid {
                self.audioTimer.invalidate()
            }
            audioTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(AudioPlayManager.udpateMiniPlayerTime), userInfo: nil, repeats: true)
            RunLoop.main.add(self.audioTimer, forMode: .default)
            audioTimer.fire()
        } else {
            if player.isPlaying {
                player.pause()
            }
            if audioTimer.isValid {
                self.audioTimer.invalidate()
            }
        }
    }
    
    // MARK: - Set audio notification on mobile application -
    private func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()

        setupNowPlaying()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if let playerAV = playerAV, !playerAV.isPlaying {
                self.playPauseAudio(true)
                NotificationCenter.default.post(name: remoteCommandName, object: nil, userInfo: ["isPlaying": false])
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
    private func setupNowPlaying() {
        // Define Now Playing Info
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()

        if let audioList = audioList, currentAudio > 0 {
            let audio = audioList[currentAudio]
            nowPlayingInfo[MPMediaItemPropertyTitle] = audio.Title
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = audio.Story.Name
            nowPlayingInfo[MPMediaItemPropertyArtist] = "Story"
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
            MPMediaItemArtwork(boundsSize: audio.Image.size) { size in
                    return audio.Image
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
    @objc private func itemDidFinishPlaying(notification: NSNotification) {
        //if let player = playerAV, player.isPlaying {
        audioTimer.invalidate()
        if let currentItem = playerAV?.currentItem, miniVController.startTimeLabel != nil {
            // Get the current time in seconds
            let duration = currentItem.duration.seconds
            miniVController.startTimeLabel.text = AudioPlayManager.formatTimeFor(seconds: 0)
            miniVController.endTimeLabel.text = AudioPlayManager.formatTimeFor(seconds: duration)
            miniVController.progressBar.progress = 0.0
            miniVController.progressBar.setNeedsDisplay()
            if let player = playerAV {
                miniVController.playButton.isSelected = !player.isPlaying
            }
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
//        if let url = audioURL {
//            configAudio(isNonStop: isNonStop)
//        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FinishedPlaying"), object: nil)
    }
    
    // MARK: - Add mini player to controller
    public func addMiniPlayer(_ controller: UIViewController, bottomConstraint: NSLayoutConstraint = NSLayoutConstraint()) {
        //currVController.view.viewWithTag(AudioPlayManager.miniViewTag)?.removeFromSuperview()
        miniVController.view.removeFromSuperview()
        miniVController = UIStoryboard.init(name: Constants.Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "MiniAudioViewController") as! MiniAudioViewController
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
        if let audioList = audioList, currentAudio > 0 {
            let audio = audioList[currentAudio]
            miniVController.songTitle.text = audio.Title
            miniVController.songImage.image = audio.Image
        }
        
        udpateMiniPlayerTime()
        
        if let player = playerAV, player.isPlaying {
            self.playPauseAudio(true)
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
                miniVController.startTimeLabel.text = playhead > 0 ? AudioPlayManager.formatTimeFor(seconds: playhead + 1) : AudioPlayManager.formatTimeFor(seconds: playhead)
            }
            if !duration.isNaN {
                miniVController.endTimeLabel.text = AudioPlayManager.formatTimeFor(seconds: duration)
            }
            if !playhead.isNaN && !currentItem.duration.seconds.isNaN{
                miniVController.progressBar.progress = Float(playhead / currentItem.duration.seconds)
            }
            
            if !duration.isNaN && (duration >= 5.0 && duration <= 6.0) {
                PromptVManager.present(currVController, verifyTitle: audioList![currentAudio].Title, verifyMessage: audioList![nextAudio].Title, image: nil, isAudioView: true, audioImage: audioList![nextAudio].Image)
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
            playPauseAudio(false)
        }
    }
    
    // MARK: - Click on miniplayer play pause button
    @objc private func tapOnPlayMini(_ sender: UIButton) {
        guard let player = AudioPlayManager.shared.playerAV else { return }
        self.playPauseAudio(!player.isPlaying)
    }
    
    // MARK: - Close miniplayer
    @objc private func tapOnCloseMini(_ sender: UIButton) {
        if isNonStop {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "closeMiniPlayer"), object: nil)
        }
        isMiniPlayerActive = false
        removeMiniPlayer()
    }
    
    // MARK: - Click on miniplayer
    @objc private func tapOnMiniPlayer(_ sender: UIButton) {
        if isNonStop {
            let nonStopViewView = UIStoryboard.init(name: Constants.Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "NonStopViewController") as! NonStopViewController
            nonStopViewView.existingAudio = true
            currVController.navigationController?.pushViewController(nonStopViewView, animated: true)
        } else {
            let nowPlayingView = UIStoryboard.init(name: Constants.Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "NowPlayViewController") as! NowPlayViewController
            nowPlayingView.existingAudio = true
            currVController.navigationController?.pushViewController(nowPlayingView, animated: true)
        }
    }
    
    
    // MARK: - Play next or previous audio
    private func nextPrevPlay(_ isNext: Bool = true) {
        // Check current audio supported or not
        var isSupported = true
        if let audioUrl = URL(string: audioList![isNext ? nextAudio : prevAudio].File) {
            let fileName = NSString(string: audioUrl.lastPathComponent)
            if !supportedAudioExtenstion.contains(fileName.pathExtension.lowercased()) {
                Snackbar.showErrorMessage("Audio File \"\(fileName)\" is not supported!")
                isSupported = false
            }
        }
        
        // Set current auio index
        let currentAudioNow = isNext ? nextAudio : prevAudio
        guard let audioList = AudioPlayManager.shared.audioList else {
            Snackbar.showAlertMessage("No next audio found!")
            return
        }
        
        //Set up next previous audio index
        currentAudio = currentAudioNow
        nextAudio = audioList.count - 1 > currentAudioNow ? currentAudioNow + 1 : 0
        prevAudio = currentAudioNow > 0 ? currentAudioNow - 1 : audioList.count - 1
        audio = audioList[currentAudio]
        
        if isSupported {
            // Configure audio data
            self.playerAV?.pause()
            self.playerAV = nil
            if audioTimer.isValid {
                audioTimer.invalidate()
            }
            self.initPlayerManager(true, getMeters: false, completionHandler: { [self] success in
                self.playPauseAudio(true)
                if miniVController.songTitle != nil  {
                    // Update miniplayer
                    miniVController.songTitle.text = audioList[currentAudio].Title
                    miniVController.songImage.image = audioList[currentAudio].Image
                }
            })
        } else {
            // Check next or previous audio
            self.nextPrevPlay(isNext)
        }
    }
    
    // Action on promt screen button
    func didActionOnPromptButton(_ tag: Int) {
        switch tag {
        case 0:
            //0 - Add to fav
            self.addToFav(audio.Story_id) { status in }
            break
        case 1:
            //1 - Once more
            if let player = playerAV {
                player.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: 1000))
            }
            miniVController.progressBar.progress = 0
            
            self.playPauseAudio(true)
            break
        default:
            //2 - play next song
            nextPrevPlay()
            break
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
    
    /*
     *  Fotmat time using seconds
     */
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
     */
    static func getAudioMeters(_ audioFileURL: URL, forChannel channelNumber: Int, completionHandler: @escaping(_ success: [Float]) -> ()) {
        
        guard let audioFile = try? AVAudioFile(forReading: audioFileURL) else {
            return
        }
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

extension AudioPlayManager {
    // Add to favourite
    private func addToFav(_ audio_story_id: Int, completion: @escaping(Bool?) -> Void) {
        Core.ShowProgress(currVController, detailLbl: "")
        FavouriteAudioClient.add(FavouriteRequest(audio_story_id: audio_story_id)) { [self] status in
            Core.HideProgress(currVController)
            completion(status)
        }
    }
    
    // Remove from favourite
    private func removeFromFav(_ audio_story_id: Int, completion: @escaping(Bool?) -> Void) {
        Core.ShowProgress(currVController, detailLbl: "")
        FavouriteAudioClient.remove(FavouriteRequest(audio_story_id: audio_story_id)) { [self] status in
            Core.HideProgress(currVController)
            completion(status)
        }
    }
}
