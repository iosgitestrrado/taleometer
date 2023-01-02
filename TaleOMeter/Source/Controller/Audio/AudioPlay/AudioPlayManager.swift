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
    static let favPlayNotification = NSNotification.Name(rawValue: "favPlayNotification")
    static let finishNotification = NSNotification.Name(rawValue: "FinishedPlaying")

    // MARK: - Public Properties -
    var playerAV: AVPlayer?
    var isMiniPlayerActive = false
    var isNonStop = false
    var isAudioPlaying = false
    var isTrivia = false
    var isFavourite = false
    var isFromFavourite = false
    var isHistory = false
    var isFromStory = false
    var isNowPlayPage = false
    var waveFormcount = 0
    var audioMetering = [Float]()
    var nowPlayingInfo = [String: Any]()
    var currentIndex = -1
    var nextIndex = -1
    var prevIndex = -1
    var audioList: [Audio]?
    var audioURL = URL(string: "")
    var currentAudio = Audio()
    var audioHistoryId = -1

    // MARK: - Private Properties -
    private var audioTimer = Timer()
    private var currVController = UIViewController()
    private var bottomConstraint = NSLayoutConstraint()
    private var miniVController = MiniAudioViewController()

    // MARK: - Configure audio as per pass url -
    public func initPlayerManager(_ isFavourite: Bool = false, isNonStop: Bool = false, getMeters: Bool = true, isHistory: Bool = false, isTrivia: Bool = false, completionHandler: @escaping(_ success: [Float]) -> ()) {
        
        guard let audList = audioList else {
            Toast.show("No audio found!")
            return
        }
        self.isNonStop = isNonStop
        self.isTrivia = isTrivia
        self.isFavourite = isFavourite
        self.isHistory = isHistory
        if audList.count > currentIndex {
            currentAudio = audList[currentIndex]
        } else {
            completionHandler([Float]())
            if let player = playerAV {
                player.pause()
                playerAV = nil
            }
            return
        }
        audioHistoryId = -1
        
        guard let url = URL(string: currentAudio.File) else { return }
        stramingAudio(url, getMeters: getMeters) { result in
            completionHandler(result)
        }
    }
    
    // MARK: - Streaming audio file -
    private func stramingAudio(_ audioUrl: URL, getMeters: Bool, completionHandler: @escaping(_ success: [Float]) -> ()) {
        // then lets create your document folder url
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        // lets create your destination file url
        var destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
       
        // if audio file is not supported change to mp3
        let fileName = NSString(string: destinationUrl.lastPathComponent)
        if !supportedAudioExtenstion.contains(fileName.pathExtension.lowercased()) {
            destinationUrl = destinationUrl.deletingPathExtension().appendingPathExtension("mp3")
        }
        
        // to check if it exists before downloading it
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            audioURL = destinationUrl
            configureAudio(getMeters) { result in
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
                    configureAudio(getMeters) { result in
                        completionHandler(result)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
//                    Toast.show(error.localizedDescription)
                    Core.HideProgress(currVController)
                }
            }).resume()
        }
    }
    
    private func configureAudio(_ getMeters: Bool, completionHandler: @escaping(_ success: [Float]) -> ()) {
        
        // Check URL exists
        guard let url = audioURL else {
            Toast.show("No audio found!")
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
        
    // MARK: - Set audio notification on mobile application -
    private func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()

        setupNowPlaying()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if let player = playerAV, !player.isPlaying {
                self.playPauseAudio(true)
                NotificationCenter.default.post(name: remoteCommandName, object: nil, userInfo: ["isPlaying": false])
                return .success
            }
            return .commandFailed
        }

        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if let player = playerAV, player.isPlaying {
                self.playPauseAudio(false)
                NotificationCenter.default.post(name: remoteCommandName, object: nil, userInfo: ["isPlaying": true])
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

        if let audioList = audioList, currentIndex >= 0 {
            let audio = audioList[currentIndex]
            nowPlayingInfo[MPMediaItemPropertyTitle] = audio.Title
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = audio.Story.Name
            nowPlayingInfo[MPMediaItemPropertyArtist] = "Story"
            
            var audioImage = defaultImage
            Core.setImage(audio.ImageUrl, image: &audioImage)
            
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
            MPMediaItemArtwork(boundsSize: CGSize(width: 140.0, height: 140.0)) { size in
                    return audioImage
            }
        }
        
        if let player = playerAV {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = Int((player.currentItem?.asset.duration.seconds)!)
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        }
        
        // Set the metadata
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    // MARK: Play pause audio with mini player update
    func playPauseAudio(_ isPlay: Bool, addToHistory: Bool = true) {
        DispatchQueue.main.async { [self] in
            guard let player = playerAV else { return }
            //Add update history
            if addToHistory && !isTrivia {
                addUpdateAudioActionHistory(isPlay)
            }
            if let miniPlayBtn = miniVController.playButton {
                miniPlayBtn.isSelected = !isPlay
            }
            isAudioPlaying = isPlay
            if isPlay {
                if !player.isPlaying {
                    player.play()
                }
                
                if audioTimer.isValid {
                    self.audioTimer.invalidate()
                }
                audioTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(AudioPlayManager.updateMiniPlayerTime), userInfo: nil, repeats: true)
                RunLoop.main.add(self.audioTimer, forMode: .default)
                audioTimer.fire()
            } else {
                if player.isPlaying {
                    player.pause()
                }
                if audioTimer.isValid {
                    self.audioTimer.invalidate()
                }
                self.updateMiniPlayerTime()
            }
            if isHistory {
                NotificationCenter.default.post(name: AudioPlayManager.finishNotification, object: nil)
            }
            if currVController.className == AuthorViewController().className {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "mainScreenPlay"), object: nil, userInfo: ["TotalStories" : audioList?.count, "IsSelected" : isAudioPlaying])
                NotificationCenter.default.post(name: AudioPlayManager.favPlayNotification, object: nil, userInfo: ["isPlaying": player.isPlaying])
            }
        }
    }
    
    // MARK: Play pause audio only
    func playPauseAudioOnly(_ isPlay: Bool, addToHistory: Bool = true) {
        guard let player = playerAV else { return }
        if addToHistory && !isTrivia {
            addUpdateAudioActionHistory(isPlay)
        }
        isAudioPlaying = isPlay
        if isPlay {
            player.play()
        } else {
            player.pause()
        }
    }
    
    // MARK: - When audio completed call function -
    @objc private func itemDidFinishPlaying(notification: NSNotification) {
        //if let player = playerAV, player.isPlaying {
        endAudioPlaying()
        DispatchQueue.main.async { [self] in
            audioTimer.invalidate()
            if let currentItem = playerAV?.currentItem, miniVController.startTimeLabel != nil {
                // Get the current time in seconds
                let duration = currentItem.duration.seconds
                miniVController.startTimeLabel.text = AudioPlayManager.formatTimeFor(seconds: 0)
                miniVController.endTimeLabel.text = AudioPlayManager.formatTimeFor(seconds: duration)
                //miniVController.progressBar.progress = 0.0
                miniVController.progressBar.setNeedsDisplay()
                if let player = playerAV {
                    miniVController.playButton.isSelected = !player.isPlaying
                }
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
            if let player = playerAV {
                player.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: 1000))
            }
            if isHistory {
                playPauseAudioOnly(false)
            }
            NotificationCenter.default.post(name: AudioPlayManager.finishNotification, object: nil)
            
            if UserDefaults.standard.bool(forKey: "AutoplayEnable") && !isNonStop && !AudioPlayManager.shared.isNowPlayPage && isMiniPlayerActive && !isTrivia {
                PromptVManager.present(currVController, verifyTitle: audioList![currentIndex].Title, verifyMessage: audioList![nextIndex].Title, isAudioView: true, audioImage: audioList![nextIndex].ImageUrl, isFavourite: isFromFavourite)
            }
        }
    }
    
    // MARK: - Play next or previous audio
    private func nextPrevPlay(_ isNext: Bool = true) {
        DispatchQueue.main.async { [self] in
        // Check current audio supported or not
//        var isSupported = true
//        if let audioUrl = URL(string: audioList![isNext ? nextIndex : prevIndex].File) {
//            let fileName = NSString(string: audioUrl.lastPathComponent)
//            if !supportedAudioExtenstion.contains(fileName.pathExtension.lowercased()) {
//                Toast.show("Audio File \"\(fileName)\" is not supported!")
//                isSupported = false
//            }
//        }
        
        // Set current auio index
        let currentAudioNow = isNext ? nextIndex : prevIndex
        guard let audioList = AudioPlayManager.shared.audioList else {
            Toast.show("No next audio found!")
            return
        }
        
        //Set up next previous audio index
        currentIndex = currentAudioNow
            nextIndex = audioList.count - 1 > currentAudioNow ? currentAudioNow + 1 : 0
            prevIndex = currentAudioNow > 0 ? currentAudioNow - 1 : audioList.count - 1
        currentAudio = audioList[currentIndex]
        
//        if isSupported {
            // Configure audio data
            self.playerAV?.pause()
            self.playerAV = nil
            if audioTimer.isValid {
                audioTimer.invalidate()
            }
            self.initPlayerManager(isFavourite, isNonStop: isNonStop, getMeters: false, isHistory: isHistory, completionHandler: { [self] success in
                self.playPauseAudio(true)
                DispatchQueue.main.async { [self] in
                    if miniVController.songTitle != nil  {
                        // Update miniplayer
                        miniVController.songTitle.text = audioList[currentIndex].Title
                        miniVController.songImage.sd_setImage(with: URL(string: audioList[currentIndex].ImageUrl), placeholderImage: defaultImage, options: [], context: nil)
                    }
                    NotificationCenter.default.post(name: AudioPlayManager.finishNotification, object: nil, userInfo: ["isNextPrev" : true])
                }
            })
//        } else {
//            // Check next or previous audio
//            self.nextPrevPlay(isNext)
//        }
        }
    }
    
    // Action on promt screen button
    func didActionOnPromptButton(_ tag: Int) {
        switch tag {
        case 0:
            //0 - Add to fav
            self.addToFav(currentAudio.Id)
            break
        case 1, 3:
            //1 - Once more //3 - Close mini player //4 - Share audio
            DispatchQueue.main.async { [self] in
                if let player = playerAV {
                    player.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: 1000))
                }
                miniVController.progressBar.progress = 0
                if tag == 1 {
                    audioHistoryId = -1
                }
                self.playPauseAudio(tag == 1)
            }
            break
        default:
            //2 - play next song
            nextPrevPlay()
            break
        }
    }
}

// MARK: - Setup audio index
extension AudioPlayManager {
    func setAudioIndex(_ currentIdx: Int = -1, isNext: Bool) {
        // Get current audio list
        guard let audioList = AudioPlayManager.shared.audioList else {
            Toast.show("No audio list found!")
            return
        }
        
        // Set current audio index
        let tempCurrentIdx = currentIdx == -1 ? (isNext ? nextIndex : prevIndex) : currentIdx
        
//        // Check current audio supported or not
//        var isSupported = true
//
//        // Check file id supported or not
//        if let audioUrl = URL(string: audioList[tempCurrentIdx].File) {
//            let fileName = NSString(string: audioUrl.lastPathComponent)
//            if !supportedAudioExtenstion.contains(fileName.pathExtension.lowercased()) {
//                Toast.show("Audio File \"\(fileName)\" is not supported!")
//                isSupported = false
//            }
//        }
//
        //Set up next previous audio index
        currentIndex = tempCurrentIdx
        nextIndex = audioList.count - 1 > tempCurrentIdx ? tempCurrentIdx + 1 : 0
        prevIndex = tempCurrentIdx > 0 ? tempCurrentIdx - 1 : audioList.count - 1
        if (audioList.count > currentIndex) {
            currentAudio = audioList[currentIndex]
        }
//        if !isSupported {
//            self.setAudioIndex(currentIndex, isNext: isNext)
//        }
    }
}

// MARK: - Setup Miniplayer -
extension AudioPlayManager {
    // MARK: - Add mini player to controller
    public func addMiniPlayer(_ controller: UIViewController, bottomConstraint: NSLayoutConstraint = NSLayoutConstraint()) {
        DispatchQueue.main.async { [self] in
            // Check mini player is already added
            if controller.view.viewWithTag(AudioPlayManager.miniViewTag) != nil, miniVController.songTitle != nil {
                // Set audio data to mini view
                if let audioList = audioList, currentIndex >= 0 {
                    let audio = audioList[currentIndex]
                    miniVController.songTitle.text = audio.Title
                    miniVController.songImage.sd_setImage(with: URL(string: audio.ImageUrl), placeholderImage: defaultImage, options: [], context: nil)
                }
                // Update audio timer
                updateMiniPlayerTime()
                // Play audio
                if let player = playerAV, player.isPlaying {
                    self.playPauseAudio(true)
                } else {
                    miniVController.playButton.isSelected = true
                }
                // Update current controller as per footer view action
                bottomConstraint.constant = UIScreen.main.bounds.size.height - miniVController.view.frame.origin.y
                if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first {
                    bottomConstraint.constant = UIScreen.main.bounds.size.height -  (miniVController.view.frame.origin.y + window.safeAreaInsets.bottom)
                }
                
                // Set audio player bottom constraint
                self.bottomConstraint = bottomConstraint
                return
            }
            
            // Remove mini player for duplication
            miniVController.view.removeFromSuperview()
            
            // Initialize mini player
            miniVController = UIStoryboard.init(name: Constants.Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "MiniAudioViewController") as! MiniAudioViewController
            
            // Set mini player view frame
            miniVController.view.frame = CGRect.init(x: 0, y: UIScreen.main.bounds.size.height - 80.0, width: UIScreen.main.bounds.size.width, height: 60.0)
            
            if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first {
                miniVController.view.frame = CGRect.init(x: 0, y: UIScreen.main.bounds.size.height - 80.0, width: UIScreen.main.bounds.size.width, height: 60.0 + window.safeAreaInsets.bottom)
            }
            
            // If footer view active update footer view frame
            if FooterManager.shared.isActive {
                if let footerView = controller.view.viewWithTag(FooterManager.viewTag) {
                    footerView.removeFromSuperview()
                    miniVController.view.frame = CGRect.init(x: 0, y: footerView.frame.origin.y - 60.0, width: UIScreen.main.bounds.size.width, height: (UIScreen.main.bounds.size.height - footerView.frame.origin.y) + 60.0)
                    footerView.frame.origin.y = 60.0
                    miniVController.view.addSubview(footerView)
                }
            }
            
            // Set audio data to mini view
            if let audioList = audioList, currentIndex >= 0 {
                let audio = audioList[currentIndex]
                miniVController.songTitle.text = audio.Title
                miniVController.songImage.sd_setImage(with: URL(string: audio.ImageUrl), placeholderImage: defaultImage, options: [], context: nil)
            }
            // Update audio timer
            updateMiniPlayerTime()
            // Play audio
            if let player = playerAV, player.isPlaying {
                self.playPauseAudio(true, addToHistory: false)
            } else {
                miniVController.playButton.isSelected = true
            }
            
            // Set button action
            miniVController.playButton.addTarget(self, action: #selector(tapOnPlayMini(_:)), for: .touchUpInside)
            miniVController.closeButton.addTarget(self, action: #selector(tapOnCloseMini(_:)), for: .touchUpInside)
            miniVController.fullViewButton.addTarget(self, action: #selector(tapOnMiniPlayer(_:)), for: .touchUpInside)
            miniVController.songImageBtn.addTarget(self, action: #selector(tapOnMiniPlayer(_:)), for: .touchUpInside)

            // Set progressbar tap recognizer
            let tapRecognizer = UITapGestureRecognizer()
            tapRecognizer.numberOfTapsRequired = 1
            miniVController.progressBar.tag = 9995555
            miniVController.progressBar.addGestureRecognizer(tapRecognizer)
            
            // Set mini player tag
            miniVController.view.tag = AudioPlayManager.miniViewTag
            
            // Update current controller as per footer view action
            bottomConstraint.constant = UIScreen.main.bounds.size.height - miniVController.view.frame.origin.y
            if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first {
                bottomConstraint.constant = UIScreen.main.bounds.size.height -  (miniVController.view.frame.origin.y + window.safeAreaInsets.bottom)
            }
            
            // Set audio player bottom constraint
            self.bottomConstraint = bottomConstraint
            
            // Add to mini player view to current controller
            controller.view.addSubview(miniVController.view)
            
            // Set audio player current controller
            currVController = controller
        }
    }
    
    // MARK: - Add mini player time and progress bar
    @objc func updateMiniPlayerTime() {
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
            
//            if UserDefaults.standard.bool(forKey: "AutoplayEnable") && !duration.isNaN && (duration >= 5.0 && duration <= 6.0) {
//                PromptVManager.present(currVController, verifyTitle: audioList![currentIndex].Title, verifyMessage: audioList![nextIndex].Title, isAudioView: true, audioImage: audioList![nextIndex].ImageUrl)
//            }
            
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
            self.updateMiniPlayerTime()
        }
    }
    
    // MARK: - Share current audio -
    static func shareAudio(_ target: UIViewController, completion: @escaping(Bool?) -> Void) {
//        let content = "Introducing tale'o'meter, An App that simplifies audio player for Every One. \nClick here to play audio \(AudioPlayManager.shared.currentAudio.File)"
        let content = "I am loving the '\(AudioPlayManager.shared.currentAudio.File)' story on taleometer."
        let controller = UIActivityViewController(activityItems: [content], applicationActivities: nil)
//        controller.excludedActivityTypes = [.postToTwitter, .postToFacebook, .postToWeibo, .message, .mail, .print, .copyToPasteboard, .assignToContact, .saveToCameraRoll, .addToReadingList, .postToVimeo, .postToFlickr, .postToTencentWeibo, .airDrop, .markupAsPDF, .openInIBooks]
        controller.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            completion(completed)
         }
        target.present(controller, animated: true) {
            
        }
       // target.present(controller, animated: true, completion: nil)
    }

    // MARK: - Remove mini player from view controller
    public func removeMiniPlayer() {
        DispatchQueue.main.async { [self] in
            bottomConstraint.constant = 0
            if FooterManager.shared.isActive {
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
        }
    }
    
    // MARK: - Click on miniplayer play pause button
    @objc private func tapOnPlayMini(_ sender: UIButton) {
        guard let player = AudioPlayManager.shared.playerAV else { return }
        NotificationCenter.default.post(name: AudioPlayManager.favPlayNotification, object: nil, userInfo: ["isPlaying": !player.isPlaying])
        self.playPauseAudio(!player.isPlaying)
    }
    
    // MARK: - Close miniplayer
    @objc private func tapOnCloseMini(_ sender: UIButton) {
        if isNonStop {
            isNonStop = false
            NotificationCenter.default.post(name: Notification.Name(rawValue: "closeMiniPlayer"), object: nil)
        }
        isMiniPlayerActive = false
        audioList = [Audio]()
        currentIndex = -1
        currentAudio = Audio()
        removeMiniPlayer()
        NotificationCenter.default.post(name: AudioPlayManager.finishNotification, object: nil)

        guard let player = AudioPlayManager.shared.playerAV else { return }
        if player.isPlaying {
            player.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: 1000))
            playPauseAudio(false)
        }
    }
    
    // MARK: - Click on miniplayer
    @objc private func tapOnMiniPlayer(_ sender: UIButton) {
        if currVController.className == AuthorViewController().className {
            currVController.navigationController?.popViewController(animated: true)
        } else if currVController.className == FavouriteViewController().className || isFavourite {
            Core.push(currVController, storyboard: Constants.Storyboard.audio, storyboardId: FavouriteViewController().className)
        } else if isNonStop {
            let nonStopView = UIStoryboard.init(name: Constants.Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "NonStopViewController") as! NonStopViewController
            nonStopView.existingAudio = true
            nonStopView.isPlayingExisting = playerAV != nil && playerAV!.isPlaying
            currVController.navigationController?.pushViewController(nonStopView, animated: true)
            self.removeMiniPlayer()
            if audioTimer.isValid {
                self.audioTimer.invalidate()
            }
        } else if isHistory {
            let hisView = UIStoryboard.init(name: Constants.Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
            currVController.navigationController?.pushViewController(hisView, animated: true)
        } else if !isTrivia {
            let nowPlayingView = UIStoryboard.init(name: Constants.Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "NowPlayViewController") as! NowPlayViewController
            nowPlayingView.existingAudio = true
            nowPlayingView.isPlaying = playerAV != nil && playerAV!.isPlaying
            currVController.navigationController?.pushViewController(nowPlayingView, animated: true)
            self.removeMiniPlayer()
            if audioTimer.isValid {
                self.audioTimer.invalidate()
            }
        }
    }
    
    private func getCurrentSecond(_ currentItem: AVPlayerItem) -> Int {
        var playhead = currentItem.currentTime().seconds
        if Int(playhead) <= 1 {
            playhead = currentItem.duration.seconds
        }
        if playhead.isNaN {
            playhead = 0
        }
        return Int(playhead)
    }
}

// MARK: - API calls -
extension AudioPlayManager {
    // Add to favourite
    private func addToFav(_ audio_story_id: Int) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(currVController)
            return
        }
        DispatchQueue.global(qos: .background).async {
            FavouriteAudioClient.add(FavouriteRequest(audio_story_id: audio_story_id)) { [self] status in
                if let st = status, st {
                    currentAudio.Is_favorite = true
                    if audioList != nil {
                        audioList![currentIndex].Is_favorite = true
                    }
                }
            }
        }
    }
    
    // Remove from favourite
    private func removeFromFav(_ audio_story_id: Int) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(currVController)
            return
        }
        DispatchQueue.global(qos: .background).async {
            FavouriteAudioClient.remove(FavouriteRequest(audio_story_id: audio_story_id)) { [self] status in
                if let st = status, st {
                    currentAudio.Is_favorite = false
                    if audioList != nil {
                        audioList![currentIndex].Is_favorite = false
                    }
                }
            }
        }
    }
    
    // Add to history
    private func addAudioToHistory() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(currVController)
            return
        }
        
        // Add history in background
        DispatchQueue.global(qos: .background).async { [self] in
            if let currentItem = playerAV?.currentItem {
                HistoryAudioClient.add(HistoryAddRequest(audio_story_id: currentAudio.Id, time: getCurrentSecond(currentItem))) { [self] result in
                    if let data = result {
                        audioHistoryId = data.Id
//                        AudioClient.addAudioAction(AddAudioActionRequest(audio_history_id: data.Id, action: AudioAction.resume.description)) { status in }
                    }
                }
            }
        }
    }
        
    // Update History
    private func updateHistory() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(currVController)
            return
        }
        // Update history in background
        DispatchQueue.global(qos: .background).async { [self] in
            if let currentItem = playerAV?.currentItem {
                HistoryAudioClient.update(HistoryUpdateRequest(audio_history_id: audioHistoryId, time: getCurrentSecond(currentItem))) { status in
                    if let st = status, st {
                        AudioClient.addAudioAction(AddAudioActionRequest(audio_history_id: self.audioHistoryId, action: AudioAction.pause.description)) { status in }
                    }
                }
            }
        }
    }
    
    // Add audio story action and update history
    private func updateHistoryAction(_ isPlay: Bool) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(currVController)
            return
        }
        // Update history in background
        DispatchQueue.global(qos: .background).async { [self] in
            if let currentItem = playerAV?.currentItem {
                AudioClient.addAudioAction(AddAudioActionRequest(audio_history_id: audioHistoryId, action: isPlay ? AudioAction.resume.description : AudioAction.pause.description, time: getCurrentSecond(currentItem))) { status in }
            }
        }
    }
    
    // Add update audio history with audio action
    private func addUpdateAudioActionHistory(_ isPlay: Bool) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(currVController)
            return
        }
        audioHistoryId == -1 ? self.addAudioToHistory() : self.updateHistoryAction(isPlay)
    }
    
    // End Audio Playing
    private func endAudioPlaying() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(currVController)
            return
        }
        // Update history in background
        DispatchQueue.global(qos: .background).async { [self] in
            AudioClient.endAudioPlaying(EndAudioRequest(audio_history_id: audioHistoryId)) { status in }
        }
    }
}

// MARK: - Other methods
extension AudioPlayManager {
    
    // MARK: Convert seconds to current time for audio
    static func getHoursMinutesSecondsFromString(seconds: Double) -> String {
        let secs = Int(seconds)
        let hours = secs / 3600
        let minutes = (secs % 3600) / 60
        let seconds = (secs % 3600) % 60
        var durationStr = ""
        if hours > 0 {
            durationStr = "\(hours) hr "
        }
        if minutes > 0 {
            durationStr = "\(durationStr) \(minutes) min "
        }
        if seconds > 0 {
            durationStr = "\(durationStr) \(seconds) sec "
        }
        if durationStr.isBlank {
            durationStr = "0 sec"
        }
        return durationStr
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
     *  Fotmat time using seconds
     */
    static func formatTimeHMSFor(seconds: Double) -> String {
        let result = getHoursMinutesSecondsFrom(seconds: seconds)
        var hoursString = "\(result.hours)"
        if hoursString.utf8.count == 1 {
            hoursString = "0\(result.hours)"
        }
        var minutesString = "\(result.minutes)"
        if minutesString.utf8.count == 1 {
            minutesString = "0\(result.minutes)"
        }
        var secondsString = "\(result.seconds)"
        if secondsString.utf8.count == 1 {
            secondsString = "0\(result.seconds)"
        }
        return "\(hoursString):\(minutesString):\(secondsString)"
    }
    
    /*
     *  Calculate audio metering
     */
    static func getAudioMeters(_ audioFileURL: URL, forChannel channelNumber: Int, completionHandler: @escaping(_ success: [Float]) -> ()) {
        
        guard let audioFile = try? AVAudioFile(forReading: audioFileURL) else {
            AudioPlayManager.shared.isMiniPlayerActive = false
            Toast.show("No audio file found")
            Core.HideProgress(AudioPlayManager.shared.currVController)
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
