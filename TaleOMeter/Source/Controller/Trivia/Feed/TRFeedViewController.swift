//
//  TRFeedViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 03/03/22.
//

import UIKit
import AVKit
import SwiftyJSON
import NVActivityIndicatorView

var profilePic: UIImage?

class TRFeedViewController: UIViewController {
    
    // MARK: - Weak Properties -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tblBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Public Properties
    var categoryId = -1
    var redirectToPostId = -1
    var redirectToCommId = -1
    var isFromNotifPostId = -1

    // MARK: - Private Properties -
    private let viewMoreText = "--------------------  View More  --------------------"
    private struct CellItem {
        var cellId = String()
        var data = CellData()
    }
    private var postData = [TriviaPost]()
    private var cellDataArray: [CellItem] = [CellItem]()
    private let messageString = "Write A Comment..."
    private var keyboardHeight: CGFloat = 0
    
    private var footerView = UIView()
    private var morePage = true
    private var pageNumber = 1
    private var showNoData = 0
    private let darkBlueT = UIColor(displayP3Red: 84.0 / 255.0, green: 85.0 / 255.0, blue: 135.0 / 255.0, alpha: 1.0)
    private var videoPostId = -1
    private var lastVideoPostId = -1
    
    private var audioPostId = -1
    private var lastaudioPostId = -1

    private var myPlayerViewController = AVPlayerViewController()
    private var videoPlayIndex = -1
    private var videoPlayingIndex = -1
    private var audioPlayIndex = -1
    private var audioPlayingIndex = -1

    private var audioList = [Audio]()
    private var audioTimer = Timer()
    
//    private var playButtonAudio = UIButton()
//    private var videoButtonAudio = UIButton()
    private var startTimeLabelAudio: UILabel?
    private var endTimeLabelAudio: UILabel?
    private var progressBarAudio: UIProgressView?
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "NoDataTableViewCell")
        Core.initFooterView(self, footerView: &footerView)
        self.hideKeyboard()
        if let profData = Login.getProfileData() {
            profilePic = UIImage(data: profData.ImageData)
        }
        pageNumber = 1
        if categoryId != -2 {
            self.getTriviaPosts()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserData(_:)), name: Notification.Name(rawValue: "updateUserData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tapOnNotification(_:)), name: Notification.Name(rawValue: "tapOnNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishedPlaying(_:)), name: AudioPlayManager.finishNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true, backImage: true)
        if audioTimer.isValid {
            self.audioTimer.invalidate()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if audioTimer.isValid {
            self.audioTimer.invalidate()
        }
    }
    
    // MARK: Add into activity log
    private func addActivityLog(_ isDaily: Bool = false) {
        DispatchQueue.global(qos: .background).async { [self] in
            ActivityClient.userActivityLog(UserActivityRequest(post_id: redirectToPostId >= 0 ? "\(redirectToPostId)" : "", category_id: categoryId >= 0 ? "\(categoryId)" : "", screen_name: isDaily ? Constants.ActivityScreenName.triviaDaily : Constants.ActivityScreenName.triviaCategory, type: Constants.ActivityType.trivia)) { status in
            }
        }
    }
    
    // MARK: Add into activity log for comment
    private func addCommentActivityLog(_ postId: Int) {
        if !Reachability.isConnectedToNetwork() {
            return
        }
        DispatchQueue.global(qos: .background).async { [self] in
            ActivityClient.userActivityLog(UserActivityRequest(post_id: postId >= 0 ? "\(postId)" : "", category_id: categoryId >= 0 ? "\(categoryId)" : "", screen_name: Constants.ActivityScreenName.triviaComment, type: Constants.ActivityType.trivia)) { status in
            }
        }
    }
    
    @objc private func updateUserData(_ notification: Notification) {
        if let profData = Login.getProfileData() {
            profilePic = UIImage(data: profData.ImageData)
        }
        self.setTableViewCells()
    }
    
    @objc private func tapOnNotification(_ notification: Notification) {
        if let catId = notification.userInfo?["NotificationCategoryId"] as? Int, catId != -2 {
            if let psId = notification.userInfo?["NotificationPostId"] as? Int {
                redirectToPostId = psId
                isFromNotifPostId = psId
               // redirectToPostId = 1
            }
            if let comId = notification.userInfo?["NotificationCommentId"] as? Int {
                redirectToCommId = comId
            }
            pageNumber = 1
            categoryId = catId
            self.getTriviaPosts()
        }
    }
    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return .landscape
//    }
//
//    override var shouldAutorotate: Bool {
//        return true
//    }
    
//    // MARK: - Initialize table footer view
//    func initFooterView() {
//        footerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: Double(self.view.frame.size.width), height: 60.0))
//
//        let frame = CGRect(x: (self.view.frame.size.width / 2.0) - 30.0, y: 5.0, width: 60.0, height: 60.0)
//        let activityIndicator = NVActivityIndicatorView(frame: frame)
//        activityIndicator.tag = 10
//        activityIndicator.type = .ballSpinFadeLoader// .ballRotateChase // add your type
//        activityIndicator.color = UIColor(displayP3Red: 213.0 / 255.0, green: 40.0 / 255.0, blue: 54.0 / 255.0, alpha: 1.0) // add your color
//        activityIndicator.tag = 9566
//        activityIndicator.startAnimating()
//
//        footerView.addSubview(activityIndicator)
//        footerView.isHidden = false
//    }
       
    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
        if let textContainer = window.viewWithTag(9998) {
            textContainer.removeFromSuperview()
        }
        self.sideMenuController!.toggleRightView(animated: true)
    }
    
    // MARK: Keyboard will show
    @objc private func keyboardWillShowNotification(notification: Notification) {
//        if keyboardHeight != 0 {
//            self.tblBottomConstraint.constant = keyboardHeight
//            return
//        }
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue  {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            self.tblBottomConstraint.constant = keyboardHeight
        }
    }
    
    // MARK: Keyboard will Hide
    @objc private func keyboardWillHideNotification(notification: Notification) {
        self.tblBottomConstraint.constant = 0
    }
    
    @objc private func tapOnAnswer(_ sender: UIButton) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        if let rowIndex = sender.layer.value(forKey: "RowIndex") as? Int {
            if cellDataArray[rowIndex].cellId == FeedCellIdentifier.question || cellDataArray[rowIndex].cellId == FeedCellIdentifier.questionVideo {
                if postData[sender.tag].Value.isBlank {
                    if let textFlield = postData[sender.tag].TextField {
                        Validator.showRequiredError(textFlield)
                    }
                    return
                }
                if !postData[sender.tag].User_opened {
                    self.viewPost(sender.tag)
                }
                Core.ShowProgress(self, detailLbl: "Submitting Answer...")
                TriviaClient.submitAnswer(SubmitAnswerRequest(post_id: postData[sender.tag].Post_id, answer: postData[sender.tag].Value)) { [self] status in
                    if let st = status, st {
                        postData[sender.tag].Value = ""
                        self.getComments(postId: postData[sender.tag].Post_id, postIndex: sender.tag)
                        addCommentActivityLog(postData[sender.tag].Post_id)
                    } else {
                        Core.HideProgress(self)
                    }
                }
            } else {
                Core.ShowProgress(self, detailLbl: "")
                TriviaClient.getAnswers(PostIdRequest(post_id: postData[sender.tag].Post_id)) { [self] response in
                    if let data = response {
                        PromptVManager.present(self, verifyTitle: data.Answer_text, verifyMessage: data.Answer_text, queImage:  postData[sender.tag].Question_media_url, ansImage: data.Answer_text.isBlank ? data.Answer_image_url : "", isQuestion: true, closeBtnHide: true)
                    }
                    Core.HideProgress(self)
                }
            }
        }
    }
    
    // MARK: Tap on view more comment
    @objc private func tapOnViewMore(_ sender: UIButton) {
        if !postData[sender.tag].IsExpanded {
            postData[sender.tag].IsExpanded = true
            self.setTableViewCells()
        }
    }
    
    // MARK: Tap on view previous reply
    @objc private func tapOnViewPrevReply(_ sender: UIButton) {
        if let comIndex = sender.layer.value(forKey: "CommentIndex") as? Int,  !postData[sender.tag].Comments[comIndex].IsExpanded {
            postData[sender.tag].Comments[comIndex].IsExpanded = true
            self.setTableViewCells()
        }
    }
    
    // MARK: Tap on post button
    @objc private func tapOnPost(_ sender: UIButton) {
        sender.isUserInteractionEnabled  = false
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            sender.isUserInteractionEnabled  = true
            return
        }
        if let rowIndex = sender.layer.value(forKey: "RowIndex") as? Int {
            if cellDataArray[rowIndex].cellId == FeedCellIdentifier.post {
                if postData[sender.tag].Value.isBlank {
                    if let textView = postData[sender.tag].CommTextView {
                        Validator.showRequiredErrorTextView(textView)
                    }
                    sender.isUserInteractionEnabled  = true
                    return
                }
                // Add new comment
                Core.ShowProgress(self, detailLbl: "")
                addComment(postData[sender.tag].Post_id, commentId: nil, comment: postData[sender.tag].Value) { [self] status in
                    if let st = status, st {
                        self.getComments(postId: postData[sender.tag].Post_id, postIndex: sender.tag)
                    } else {
                        Core.HideProgress(self)
                    }
                    postData[sender.tag].Value = ""
                    sender.isUserInteractionEnabled  = true
                    
                }
            } else if cellDataArray[rowIndex].cellId == FeedCellIdentifier.replyPost, let commIndex = sender.layer.value(forKey: "CommentIndex") as? Int {
                if postData[sender.tag].Value.isBlank {
                    if let textView = postData[sender.tag].RepTextView {
                        Validator.showRequiredErrorTextView(textView)
                    }
                    sender.isUserInteractionEnabled  = true
                    return
                }
                Core.ShowProgress(self, detailLbl: "")
                // Add new reply in comment
                addComment(postData[sender.tag].Post_id, commentId: postData[sender.tag].Comments[commIndex].Comment_id, comment: postData[sender.tag].Value) { [self] status in
                    if let st = status, st {
                        self.getComments(true, postId: postData[sender.tag].Post_id, postIndex: sender.tag)
                    } else {
                        Core.HideProgress(self)
                    }
                    postData[sender.tag].Value = ""
                    sender.isUserInteractionEnabled  = true
                }
            }
        }
    }
    
    // MARK: Tap on reply Button
    @objc private func tapOnReply(_ sender: UIButton) {
        if let cellIndex = sender.layer.value(forKey: "CellIndex") as? Int, let commentIndex = sender.layer.value(forKey: "CommentIndex") as? Int, let replyIndex = sender.layer.value(forKey: "ReplyIndex") as? Int {
            if cellDataArray.contains(where: { cell in cell.cellId == FeedCellIdentifier.replyPost}) {
                cellDataArray.removeAll(where: { cell in cell.cellId == FeedCellIdentifier.replyPost })
            }
            cellDataArray.insert(CellItem(cellId: FeedCellIdentifier.replyPost, data: CellData(imageUrl: "", profilePic: profilePic, title: "", description: "", time: "", index: cellIndex, commentIndex: commentIndex, replyIndex: replyIndex)), at: sender.tag + 1)
            self.tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                if let replyPostIndex = cellDataArray.firstIndex(where: { $0.cellId == FeedCellIdentifier.replyPost }), let cell = tableView.cellForRow(at: IndexPath(row: replyPostIndex, section: 0)) as? FeedCellView, let textView = cell.descText {
                    textView.becomeFirstResponder()
                }
            }
        }
    }
    
    // MARK: Tap on image Button
    @objc private func tapOnQuestionImage(_ sender: UIButton) {
        if !postData[sender.tag].User_opened {
            self.viewPost(sender.tag)
        }
    }
    
    // MARK: Tap on video Button
    @objc private func tapOnVideo(_ sender: UIButton) {
        if AudioPlayManager.shared.isMiniPlayerActive {
            guard let player = AudioPlayManager.shared.playerAV else { return }
            if player.isPlaying {
                AudioPlayManager.shared.playPauseAudio(false)
            }
            AudioPlayManager.shared.isNonStop = false
            AudioPlayManager.shared.isHistory = false
            AudioPlayManager.shared.isFavourite = false
            AudioPlayManager.shared.isMiniPlayerActive = false
            AudioPlayManager.shared.removeMiniPlayer()
        }
        
        if let rowIndex = sender.layer.value(forKey: "RowIndex") as? Int {
            videoPlayIndex = rowIndex
            if !postData[sender.tag].User_opened {
                self.viewPost(sender.tag)
                postData[sender.tag].User_opened = true
            }
            if postData[sender.tag].Question_type.lowercased() == "audio" {
                if rowIndex != audioPlayingIndex || AudioPlayManager.shared.playerAV == nil || !AudioPlayManager.shared.isTrivia {
                    if audioPostId != -1 {
                        lastaudioPostId = audioPostId
                    }
                    audioPostId = postData[sender.tag].Post_id
                } else {
//                    AudioPlayManager.shared.playPauseAudioOnly(sender.isSelected, addToHistory: false)
//                    self.playPauseAudio(sender.isSelected, rowIndex: rowIndex)
                    AudioPlayManager.shared.playPauseAudioOnly(true, addToHistory: false)
                    self.playPauseAudio(true, rowIndex: rowIndex)
                    sender.isSelected = !sender.isSelected
                }
            } else {
                if videoPostId != -1 {
                    lastVideoPostId = videoPostId
                }
                videoPostId = postData[sender.tag].Post_id
            }
            self.tableView.reloadData()
        } else {
            Toast.show("No video found!")
        }
    }
    
    // MARK: - Adding video player into view
    private func addVideoPlayer(_ videoView: UIButton, videoURL: URL, rowIndex: Int, postType: String) {
        if audioPlayingIndex != -1 {
            playPauseAudio(false, rowIndex: audioPlayingIndex)
            AudioPlayManager.shared.isMiniPlayerActive = false
            audioPlayingIndex = -1
        }
        if videoPlayingIndex == rowIndex {
            videoView.addSubview(myPlayerViewController.view)
        } else {
            if let playerV = myPlayerViewController.player {
                playerV.pause()
                if lastVideoPostId != -1, let playhead = playerV.currentItem?.currentTime().seconds, let duration = playerV.currentItem?.duration.seconds {
                    addVideoActivity(lastVideoPostId, duration: AudioPlayManager.formatTimeHMSFor(seconds: duration.isNaN ? 0 : duration), currentTime: AudioPlayManager.formatTimeHMSFor(seconds: playhead.isNaN ? 0 : playhead), status: "stop")
                }
                myPlayerViewController.view.removeFromSuperview()
            }
            myPlayerViewController = AVPlayerViewController()
            myPlayerViewController.view.tag = 9898998
            let player = AVPlayer(url: videoURL)
            myPlayerViewController.player = player
            myPlayerViewController.view.frame.size.height = videoView.frame.size.height
            myPlayerViewController.view.frame.size.width = videoView.frame.size.width
            videoView.addSubview(myPlayerViewController.view)
            myPlayerViewController.showsPlaybackControls = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
                myPlayerViewController.player?.play()
                myPlayerViewController.player?.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                    if let player = self.myPlayerViewController.player, let duration = player.currentItem?.duration.seconds {
                        addVideoActivity(videoPostId, duration: AudioPlayManager.formatTimeHMSFor(seconds: duration.isNaN ? 0 : duration), currentTime: AudioPlayManager.formatTimeHMSFor(seconds: 0), status: "start")
                    }
                }
            }
            videoPlayingIndex = rowIndex
        }
    }
    
    // MARK: - Adding audio player into view
    private func addAudioPlayer(_ postId: Int, rowIndex: Int, isPlayNow: Bool = true) {
        if videoPlayingIndex != -1 {
            if let playerV = myPlayerViewController.player {
                playerV.pause()
                if lastVideoPostId != -1, let playhead = playerV.currentItem?.currentTime().seconds, let duration = playerV.currentItem?.duration.seconds {
                    addVideoActivity(lastVideoPostId, duration: AudioPlayManager.formatTimeHMSFor(seconds: duration.isNaN ? 0 : duration), currentTime: AudioPlayManager.formatTimeHMSFor(seconds: playhead.isNaN ? 0 : playhead), status: "stop")
                }
                myPlayerViewController.view.removeFromSuperview()
            }
            videoPlayingIndex = -1
        }
        if audioPlayingIndex != rowIndex {
            if AudioPlayManager.shared.isMiniPlayerActive, let audioPlay = AudioPlayManager.shared.playerAV, AudioPlayManager.shared.currentAudio.Id == postId {
                audioPlayingIndex = rowIndex
                playPauseAudio(audioPlay.isPlaying, rowIndex: rowIndex)
                if (!audioPlay.isPlaying) {
                    self.tableView.reloadData()
                }
            } else {
                // Start progress
                Core.ShowProgress(self, detailLbl: "Streaming Audio")
                AudioPlayManager.shared.audioList = audioList
                if let index = audioList.firstIndex(where: { $0.Id == postId }) {
                    AudioPlayManager.shared.setAudioIndex(index, isNext: false)
                }
                // Initialize audio play in audio player manager
                AudioPlayManager.shared.initPlayerManager(getMeters: false, isTrivia: true, completionHandler: { [self] success in
                    // Config audio in current view
                    AudioPlayManager.shared.playPauseAudioOnly(isPlayNow, addToHistory: false)
                    playPauseAudio(isPlayNow, rowIndex: rowIndex)
                    // Hide progress
                    Core.HideProgress(self)
                    audioPlayingIndex = rowIndex
                })
            }
        }
    }
    
    @objc func tapOnAudioPlay(_ sender: UIButton) {
        if let rowIndex = sender.layer.value(forKey: "RowIndex") as? Int {
            videoPlayIndex = rowIndex
            if rowIndex != audioPlayingIndex || AudioPlayManager.shared.playerAV == nil || !AudioPlayManager.shared.isTrivia {
                if !postData[sender.tag].User_opened {
                    self.viewPost(sender.tag)
                    postData[sender.tag].User_opened = true
                }
                if audioPostId != -1 {
                    lastaudioPostId = audioPostId
                }
                audioPostId = postData[sender.tag].Post_id
            } else {
                AudioPlayManager.shared.playPauseAudioOnly(sender.isSelected, addToHistory: false)
                self.playPauseAudio(sender.isSelected, rowIndex: rowIndex)
                sender.isSelected = !sender.isSelected
            }
            self.tableView.reloadData()
        } else {
            Toast.show("No audio found!")
        }
    }
    
    // MARK: Play pause audio with mini player update
    func playPauseAudio(_ isPlay: Bool, rowIndex: Int) {
//        DispatchQueue.main.async { [self] in
            guard let player = AudioPlayManager.shared.playerAV else { return }
//            if let miniPlayBtn = miniVController.playButton {
//                miniPlayBtn.isSelected = !isPlay
//            }
        if audioTimer.isValid {
            self.audioTimer.invalidate()
        }
        if isPlay {
            if !AudioPlayManager.shared.isAudioPlaying {
                player.play()
            }
            DispatchQueue.main.async { [self] in
                audioTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(TRFeedViewController.updateAudioPlayerTime), userInfo: nil, repeats: true)
                RunLoop.main.add(self.audioTimer, forMode: .default)
                audioTimer.fire()
                tableView.reloadData()
            }
        } else {
            if player.isPlaying {
                player.pause()
            }
        }
        if let currentItem = AudioPlayManager.shared.playerAV?.currentItem {
            let playhead = currentItem.currentTime().seconds
            let duration = currentItem.duration.seconds
            addAudioActivity(self.postData[rowIndex].Post_id, duration: duration.isNaN ? "0" : "\(duration)", currentTime: "\(playhead)", status: isPlay ? "start" : "pause")
        }
//        }
    }
    
    // MARK: - When audio playing is finished -
    @objc private func itemDidFinishedPlaying(_ notification: Notification) {
        self.playPauseAudio(false, rowIndex: audioPlayingIndex)
        self.tableView.reloadRows(at: [IndexPath(row: audioPlayingIndex, section: 0)], with: .none)
        audioPlayingIndex = -1
    }
    
    // MARK: - Add mini player time and progress bar
    @objc func updateAudioPlayerTime() {
        if audioPlayingIndex > -1 {
            if let audioPlayer = AudioPlayManager.shared.playerAV, let currentItem = audioPlayer.currentItem {
                // Get the current time in seconds
                let playhead = currentItem.currentTime().seconds
                let duration = currentItem.duration.seconds - currentItem.currentTime().seconds
                if !playhead.isNaN && self.startTimeLabelAudio != nil {
                    self.startTimeLabelAudio?.text = playhead > 0 ? AudioPlayManager.formatTimeFor(seconds: playhead + 1) : AudioPlayManager.formatTimeFor(seconds: playhead)
                }
                if !duration.isNaN && self.endTimeLabelAudio != nil {
                    self.endTimeLabelAudio?.text = AudioPlayManager.formatTimeFor(seconds: duration)
                }
                if !playhead.isNaN && !currentItem.duration.seconds.isNaN && self.progressBarAudio != nil {
                    self.progressBarAudio?.progress = Float(playhead / currentItem.duration.seconds)
                }
            }
//            self.tableView.reloadRows(at: [IndexPath(row: audioPlayingIndex, section: 0)], with: .none)
        }
//        if let currentItem = AudioPlayManager.shared.playerAV?.currentItem {
//            // Get the current time in seconds
//            let playhead = currentItem.currentTime().seconds
//            let duration = currentItem.duration.seconds - currentItem.currentTime().seconds
            // Format seconds for human readable string
            /*if !playhead.isNaN {
                miniVController.startTimeLabel.text = playhead > 0 ? AudioPlayManager.formatTimeFor(seconds: playhead + 1) : AudioPlayManager.formatTimeFor(seconds: playhead)
            }
            if !duration.isNaN {
                miniVController.endTimeLabel.text = AudioPlayManager.formatTimeFor(seconds: duration)
            }
            if !playhead.isNaN && !currentItem.duration.seconds.isNaN {
                miniVController.progressBar.progress = Float(playhead / currentItem.duration.seconds)
            }
            miniVController.progressBar.setNeedsDisplay()*/
//            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playhead
//            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
//        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            if lastVideoPostId == -1, let player = self.myPlayerViewController.player, let playhead = player.currentItem?.currentTime().seconds, let duration = player.currentItem?.duration.seconds {
                if !player.isPlaying {
                    addVideoActivity(videoPostId, duration: AudioPlayManager.formatTimeHMSFor(seconds: duration.isNaN ? 0 : duration), currentTime: AudioPlayManager.formatTimeHMSFor(seconds: playhead.isNaN ? 0 : playhead), status: !playhead.isNaN && duration == playhead ? "stop" : "pause")
                } else {
                   //addVideoActivity(videoPostId, duration: AudioPlayManager.formatTimeHMSFor(seconds: duration.isNaN ? 0 : duration), currentTime: AudioPlayManager.formatTimeHMSFor(seconds: playhead.isNaN ? 0 : playhead), status: "start")
                }
//                print(player.isPlaying)
//                print(playhead)
//                print(AudioPlayManager.formatTimeHMSFor(seconds: duration.isNaN ? 0 : duration))
//                print(AudioPlayManager.formatTimeHMSFor(seconds: playhead.isNaN ? 0 : playhead))
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func addVideoActivity(_ postId: Int, duration: String, currentTime: String, status: String) {
        if videoPostId == -1 {
            return
        }
        if !Reachability.isConnectedToNetwork() {
            return
        }
        DispatchQueue.global(qos: .background).async { [self] in
            ActivityClient.videoActivityLog(TriviaVideoActivityRequest(post_id: postId, duration: duration, time: currentTime, status: status, is_notification: videoPostId == isFromNotifPostId ? 1 : 0)) { [self] status in
                if lastVideoPostId != -1 {
                    lastVideoPostId = -1
                }
            }
        }
    }
    
    private func addAudioActivity(_ postId: Int, duration: String, currentTime: String, status: String) {
        if audioPostId == -1 {
            return
        }
        if !Reachability.isConnectedToNetwork() {
            return
        }
        DispatchQueue.global(qos: .background).async { [self] in
            ActivityClient.audioActivityLog(TriviaVideoActivityRequest(post_id: postId, duration: duration, time: currentTime, status: status, is_notification: audioPostId == isFromNotifPostId ? 1 : 0)) { [self] status in
                if lastaudioPostId != -1 {
                    lastaudioPostId = -1
                }
            }
        }
    }
    
    // MARK: - Click on done button of keyborad toolbar
    @objc private func doneToolbar(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
    
    // MARK: - Play a video in video controller
    private func playVideo(_ row: Int) {
        
    }
}

extension TRFeedViewController {
    // MARK: - Get trivia posts
    @objc func getTriviaPosts(_ replyExpanded: Bool = false, showProgress: Bool = false) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self, methodName: "getTriviaPosts:showProgress:")
            return
        }
        if !showProgress {
            Core.ShowProgress(self, detailLbl: "")
        }
        if pageNumber == 1 {
            addActivityLog(categoryId < 0)
        }
        if categoryId >= 0 {
            // MARK: - Get trivia posts by category
            TriviaClient.getCategoryPosts(pageNumber, req: TriviaCategoryRequest(category: categoryId)) { [self] response in
                if let data = response {
                    postData = pageNumber == 1 ? data : postData + data
                    morePage = data.count > 0
                    postData.forEach { post in
                        if post.Question_type.lowercased() == "audio" {
                            audioList.append(post.AudioStory)
                        }
                    }
                    if audioList.count > 0 {
                        if !AudioPlayManager.shared.isNonStop, !AudioPlayManager.shared.isHistory, !AudioPlayManager.shared.isFavourite, AudioPlayManager.shared.isMiniPlayerActive, AudioPlayManager.shared.playerAV != nil, let rowIndex = postData.firstIndex(where: { $0.Post_id == audioList[AudioPlayManager.shared.currentIndex].Id }) {
                            videoPlayIndex = rowIndex
                            //self.addAudioPlayer(audioList[AudioPlayManager.shared.currentIndex].Id, rowIndex: rowIndex, isPlayNow: player.isPlaying)
                        }
                    }
                }
                showNoData = 1
                setTableViewCells(replyExpanded)
                tableView.tableFooterView = UIView()
                if !showProgress {
                    Core.HideProgress(self)
                }
                if redirectToPostId != -1 && pageNumber <= 3 && postData.first(where: { $0.Post_id == redirectToPostId }) == nil {
                    pageNumber += 1
                    tableView.tableFooterView = footerView
                    if let indicator = footerView.viewWithTag(10) as? UIActivityIndicatorView {
                        indicator.startAnimating()
                    }
                    DispatchQueue.global(qos: .background).async { DispatchQueue.main.async { self.getTriviaPosts(showProgress: true) } }
                }
            }
        } else {
            // MARK: - Get trivia daily posts
            TriviaClient.getTriviaDailyPost(pageNumber) { [self] response in
                if let data = response {
                    postData = pageNumber == 1 ? data : postData + data
                    morePage = data.count > 0
                    postData.forEach { post in
                        if post.Question_type.lowercased() == "audio" {
                            audioList.append(post.AudioStory)
                        }
                    }
                    if audioList.count > 0 {
                        if !AudioPlayManager.shared.isNonStop, !AudioPlayManager.shared.isHistory, !AudioPlayManager.shared.isFavourite, AudioPlayManager.shared.isMiniPlayerActive, AudioPlayManager.shared.playerAV != nil, let rowIndex = postData.firstIndex(where: { $0.Post_id == audioList[AudioPlayManager.shared.currentIndex].Id }) {
                            videoPlayIndex = rowIndex
                            //self.addAudioPlayer(audioList[AudioPlayManager.shared.currentIndex].Id, rowIndex: rowIndex, isPlayNow: player.isPlaying)
                        }
                    }
                }
                showNoData = 1
                setTableViewCells(replyExpanded)
                
                tableView.tableFooterView = UIView()
                if !showProgress {
                    Core.HideProgress(self)
                }
                if redirectToPostId != -1 && pageNumber <= 3 && postData.first(where: { $0.Post_id == redirectToPostId }) == nil {
                    pageNumber += 1
                    tableView.tableFooterView = footerView
                    if let indicator = footerView.viewWithTag(10) as? UIActivityIndicatorView {
                        indicator.startAnimating()
                    }
                    DispatchQueue.global(qos: .background).async { DispatchQueue.main.async { self.getTriviaPosts(showProgress: true) } }
                }
            }
        }
    }
    
    // MARK: - Get comments using post id
    private func getComments(_ replyExpanded: Bool = false, postId: Int, postIndex: Int) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            Core.HideProgress(self)
            return
        }
        //Core.ShowProgress(self, detailLbl: "")
        TriviaClient.getComments(PostIdRequest(post_id: postId)) { [self] response in
            if let data = response {
                postData[postIndex].User_answer_status = true
                postData[postIndex].Comments = data
            }
            setTableViewCells(replyExpanded)
            Core.HideProgress(self)
        }
    }
    
    // MARK: - Add Commnet -
    private func addComment(_ postId: Int, commentId: Int?, comment: String, completion: @escaping(Bool?) -> Void) {
        //        DispatchQueue.global(qos: .background).async {
        TriviaClient.addComments(AddCommentRequest(post_id: postId, comment_id: commentId, comment: comment)) { status in
            completion(status)
        }
        addCommentActivityLog(postId)
        //        }
    }
    
    // MARK: View post
    private func viewPost(_ postIndex: Int) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        DispatchQueue.global(qos: .background).async { [self] in
            TriviaClient.viewPost(PostIdRequest(post_id: postData[postIndex].Post_id)) { [self] status in
                if let st = status, st {
                    postData[postIndex].User_opened = true
                }
            }
        }
    }
    
    // MARK: - Set cell for tableview
    private func setTableViewCells(_ replyExpanded: Bool = false) {
        cellDataArray = [CellItem]()
        var scrollToIndex = -1
        // each for index of post
        for index in 0..<postData.count {
            
            /// get post model
            let feed = postData[index]
            
            if feed.User_answer_status {
                /// Add Image / Video and question title cell with view answer
                cellDataArray.append(CellItem(cellId: feed.QuestionVideoURL.isBlank ? FeedCellIdentifier.image : FeedCellIdentifier.video, data: CellData(imageUrl: feed.Question_media_url, videoThumbnail: feed.Thumbnail, title: feed.Question, description: feed.Date, time: "", index: index, commentIndex: feed.Post_id)))
            } else {
                /// Add Image / Video and question title cell with submit answer
                cellDataArray.append(CellItem(cellId: feed.QuestionVideoURL.isBlank ? FeedCellIdentifier.question : FeedCellIdentifier.questionVideo, data: CellData(imageUrl: feed.Question_media_url, videoThumbnail: feed.Thumbnail, title: feed.Question, description: feed.Date, time: "", index: index, commentIndex: feed.Post_id)))
            }
            if feed.Post_id == redirectToPostId {
                scrollToIndex = cellDataArray.count - 1
            }
            /// Check comment
            if feed.Comments.count > 0 {
                
                /// comment for each
                for comIndex in 0..<feed.Comments.count {
                    
                    /// Get comment model
                    var comment = feed.Comments[comIndex]
                    if comment.Comment_id == redirectToCommId {
                        scrollToIndex = cellDataArray.count - 1
                    }
                    /// Check is explanded or not
                    if !feed.IsExpanded && comIndex == 3 {
                        /// Add view more text cell
                        cellDataArray.append(CellItem(cellId: FeedCellIdentifier.viewMore, data: CellData(imageUrl: "", title: viewMoreText, description: "", time: "", index: index, commentIndex: comIndex)))
                        break
                    }
                    
                    /// Add comment cell
                    cellDataArray.append(CellItem(cellId: FeedCellIdentifier.comment, data: CellData(imageUrl: comment.Profile_image_url, title: comment.User_name, description: comment.Comment, time: comment.Time_ago, index: index, commentIndex: comIndex)))
                    
                    /// Check reply exists
                    if comment.Reply.count > 0 {
                        
                        /// Reply for each
                        for repIndex in 0..<comment.Reply.count {
                            
                            /// Get reply model
                            let reply = comment.Reply[repIndex]
                            
                            /// If reply by user
                            if replyExpanded {
                                comment.IsExpanded = true
                            }
                            
                            /// Check Comment expanded
                            if !comment.IsExpanded && repIndex == 0 && comment.Reply_count > 1 {
                                
                                /// Get reply model
                                var lastReply = reply
                                if let lsRep = comment.Reply.last {
                                    lastReply = lsRep
                                }
                              
                                /// Add view previous reply cell
                                cellDataArray.append(CellItem(cellId: FeedCellIdentifier.moreReply, data: CellData(imageUrl: "", title: "View previous \(comment.Reply_count - 1) replies", description: "", time: "", index: index, commentIndex: comIndex)))
                                
                                /// Add reply cell
                                cellDataArray.append(CellItem(cellId: FeedCellIdentifier.reply, data: CellData(imageUrl: lastReply.Profile_image_url, title: lastReply.User_name, description: lastReply.Comment, time: lastReply.Time_ago, index: index, commentIndex: comIndex, replyIndex: comment.Reply.count - 1)))
                                break
                            }
                            
                            /// Add reply cell
                            cellDataArray.append(CellItem(cellId: FeedCellIdentifier.reply, data: CellData(imageUrl: reply.Profile_image_url, title: reply.User_name, description: reply.Comment, time: reply.Time_ago, index: index, commentIndex: comIndex, replyIndex: repIndex)))
                        }
                    }
                }
            }
            
            if feed.User_answer_status {
                /// Add post comment cell
                cellDataArray.append(CellItem(cellId: FeedCellIdentifier.post, data: CellData(imageUrl: "", profilePic: profilePic, title: "", description: "", time: "", index: index)))
            }
        }// 360 x 185 // 1280 x 660
        self.tableView.reloadData()
        if scrollToIndex > 0 {
            redirectToPostId = -1
            redirectToCommId = -1
            self.tableView.scrollToRow(at: IndexPath(row: scrollToIndex, section: 0), at: .top, animated: true)
        }
        //self.tableView.reloadSections(IndexSet(integer: 0), with: .bottom)
    }
}

// MARK: - UITableViewDataSource -
extension TRFeedViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDataArray.count > 0 ? self.cellDataArray.count : showNoData
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.cellDataArray.count <= 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataTableViewCell", for: indexPath) as? NoDataTableViewCell else { return UITableViewCell() }
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellDataArray[indexPath.row].cellId, for: indexPath) as? FeedCellView else { return UITableViewCell() }
        let cellData = cellDataArray[indexPath.row].data
        cell.configureCell(cellData,
                           cellId: cellDataArray[indexPath.row].cellId,
                           messageString: messageString, videoUrl: postData[cellData.index].QuestionVideoURL, row: indexPath.row, target: self,
                           selectors: [#selector(tapOnPost(_:)), #selector(tapOnViewMore(_:)),  #selector(tapOnViewPrevReply(_:)),  #selector(tapOnReply(_:)), #selector(doneToolbar(_:)), #selector(tapOnAnswer(_:)), #selector(tapOnVideo(_:)), #selector(tapOnQuestionImage(_:)), #selector(tapOnAudioPlay(_:))], questionType: postData[cellData.index].Question_type)
        if cell.playButton != nil {
            cell.playButton.isHidden = true
        }
        if cellDataArray[indexPath.row].cellId == FeedCellIdentifier.question || cellDataArray[indexPath.row].cellId == FeedCellIdentifier.questionVideo, let textField = cell.textField {
            textField.text = postData[cellData.index].Value
            postData[cellData.index].TextField = textField
        }
        if cellDataArray[indexPath.row].cellId == FeedCellIdentifier.post, let textView = cell.descText {
            textView.text = postData[cellData.index].Value
            if textView.text.isBlank {
                textView.text = messageString
                textView.textColor = darkBlueT
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
            postData[cellData.index].CommTextView = textView
        }
        if cellDataArray[indexPath.row].cellId == FeedCellIdentifier.replyPost, let textView = cell.descText {
            textView.text = postData[cellData.index].Value
            if textView.text.isBlank {
                textView.text = messageString
                textView.textColor = darkBlueT
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
            postData[cellData.index].RepTextView = textView
        }
        if postData[cellData.index].Question_type.lowercased() != "audio", let videoBtn1 = cell.videoButton1 {
            videoBtn1.isHidden = false
        }
        if videoPlayIndex == indexPath.row, audioPlayingIndex != -1, cell.audioView != nil, let audioPlayer = AudioPlayManager.shared.playerAV, let currentItem = audioPlayer.currentItem {
            if cell.playButton != nil {
                cell.playButton.isHidden = true
                if audioPlayer.isPlaying {
                    cell.playButton.isHidden = false
                    if let videoBtn1 = cell.videoButton1 {
                        videoBtn1.isHidden = true
                    }
                } else {
                    if let videoBtn1 = cell.videoButton1 {
                        videoBtn1.isHidden = false
                    }
                }
                cell.playButton.isSelected = !audioPlayer.isPlaying
            }
//            if cell.videoButton1 != nil {
//                cell.videoButton1.isSelected = audioPlayer.isPlaying
//            }
            if cell.songTitle != nil {
                cell.songTitle.text = postData[cellData.index].Question
            }
            // Get the current time in seconds
            let playhead = currentItem.currentTime().seconds
            let duration = currentItem.duration.seconds - currentItem.currentTime().seconds
            if cell.startTimeLabel != nil {
                if !playhead.isNaN {
                    cell.startTimeLabel.text = playhead > 0 ? AudioPlayManager.formatTimeFor(seconds: playhead + 1) : AudioPlayManager.formatTimeFor(seconds: playhead)
                }
                self.startTimeLabelAudio = cell.startTimeLabel
            }
            if cell.endTimeLabel != nil {
                if !duration.isNaN {
                    cell.endTimeLabel.text = AudioPlayManager.formatTimeFor(seconds: duration)
                }
                self.endTimeLabelAudio = cell.endTimeLabel
            }
            if cell.progressBar != nil {
                if !playhead.isNaN && !currentItem.duration.seconds.isNaN {
                    cell.progressBar.progress = Float(playhead / currentItem.duration.seconds)
                }
                self.progressBarAudio = cell.progressBar
            }
        }
        if videoPlayIndex == indexPath.row, let videoURL = URL(string: postData[cellData.index].QuestionVideoURL) {
            if postData[cellData.index].Question_type.lowercased() == "audio" && audioPlayingIndex != indexPath.row {
                self.addAudioPlayer(postData[cellData.index].Post_id, rowIndex: indexPath.row)
                if let audioView = cell.audioView {
                    audioView.isHidden = false
                }
                if let subTitle = cell.subTitleXConstraint {
                    subTitle.constant = 10.0
                }
            } else if postData[cellData.index].Question_type.lowercased() == "video" {
                if AudioPlayManager.shared.isMiniPlayerActive {
                    AudioPlayManager.shared.removeMiniPlayer()
                }
                self.addVideoPlayer(cell.videoButton, videoURL: videoURL, rowIndex: indexPath.row, postType: postData[cellData.index].Question_type)
                if let subTitle = cell.subTitleXConstraint {
                    subTitle.constant = 60.0
                }
                if let videoBtn1 = cell.videoButton1 {
                    videoBtn1.isHidden = true
                }
            }
            
        } else if let videoBtn = cell.videoButton {
            if let playerView = videoBtn.viewWithTag(9898998) {
                playerView.removeFromSuperview()
            }
            if let subTitle = cell.subTitleXConstraint {
                subTitle.constant = 10.0
            }
            if let videoThum = cellData.profilePic {
                videoBtn.setBackgroundImage(videoThum, for: .normal)
            }
            if cell.progressBar != nil && postData[cellData.index].Question_type.lowercased() == "audio"  {
                cell.progressBar.progress = 0
                if cell.endTimeLabel != nil {
                    cell.endTimeLabel.text = "00:00"
                }
                if cell.startTimeLabel != nil {
                    cell.startTimeLabel.text = "00:00"
                }
                if cell.playButton != nil {
                    cell.playButton.isSelected = true
                }
            }
        }
        return cell
    }
}

// MARK: - UITableViewDelegate -
extension TRFeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellDataArray.count <= 0 ? (showNoData == 1 ? 30 : 0) : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cellDataArray.count > 5 && indexPath.row == cellDataArray.count - 1 && self.morePage {
            //last cell load more
            pageNumber += 1
            tableView.tableFooterView = footerView
            if let indicator = footerView.viewWithTag(10) as? UIActivityIndicatorView {
                indicator.startAnimating()
            }
            DispatchQueue.global(qos: .background).async { DispatchQueue.main.async { self.getTriviaPosts(showProgress: true) } }
        }
    }
}

// MARK: - UITextViewDelegate -
extension TRFeedViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == darkBlueT {
            textView.text = nil
            textView.textColor = UIColor.white
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [self] in
            let indexPath = IndexPath(row: textView.tag, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
        textView.setError()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
       
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)

        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            textView.text = messageString
            textView.textColor = darkBlueT
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }

        // Else if the text view's placeholder is showing and the
        // length of the replacement string is greater than 0, set
        // the text color to white then set its text to the
        // replacement string
         else if textView.textColor == darkBlueT && !text.isEmpty {
            textView.textColor = UIColor.white
            textView.text = text
        }

        // For every other case, the text should change with the usual
        // behavior...
        else {
            return true
        }

        // ...otherwise return false since the updates have already
        // been made
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == darkBlueT {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if let index = textView.layer.value(forKey: "IndexVal") as? Int {
            postData[index].Value = textView.text
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty /*|| textView.text == messageString*/ {
            textView.text = messageString
            textView.textColor = darkBlueT
            //Validator.showRequiredErrorTextView(textView)
        }
    }
}

// MARK: - UITextFieldDelegate -
extension TRFeedViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [self] in
            let indexPath = IndexPath(row: textField.tag, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
        textField.setError()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text!.isBlank {
            //Validator.showRequiredError(textField)
            return
        }
        if let index = textField.layer.value(forKey: "IndexVal") as? Int {
            self.postData[index].Value = textField.text!
        }
    }
}

// MARK: - PromptViewDelegate -
extension TRFeedViewController: PromptViewDelegate {
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
        //Core.push(self, storyboard: Constants.Storyboard.trivia, storyboardId: "TRFeedViewController")
    }
}

// MARK: - NoInternetDelegate -
extension TRFeedViewController: NoInternetDelegate {
    func connectedToNetwork(_ methodName: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.perform(Selector((methodName)))
        }
    }
}
