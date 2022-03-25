//
//  HistoryViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit
import CoreMedia

class HistoryViewController: UIViewController {

    // MARK: - Weak Property -
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Private Property -
    private var audioList = [Audio]()
    private var historyList = [History]()
    private var historyData = Dictionary<String, [History]>()
    private var selectedIndex = -1
    private var selectedSection = -1
    private var currentProgressBar = UIProgressView()
    
    private var footerView = UIView()
    private var morePage = true
    private var pageNumber = 1
    private var showNoData = 0
    private var audioTimer = Timer()
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "NoDataTableViewCell")
        Core.initFooterView(self, footerView: &footerView)
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishedPlaying), name: AudioPlayManager.finishNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sideMenuController!.toggleRightView(animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getHistory()
    }

    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        self.sideMenuController!.toggleRightView(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touch = touches.first!
//        if touch.view?.tag == 9995555 {
//            let location = touch.location(in: touch.view)
//            progressBar.progress = Float(location.x / progressBar.frame.size.width)
//            if let player = AudioPlayManager.shared.playerAV, let secondDuration = player.currentItem?.duration.seconds {
//                let total = Int(secondDuration * Double(location.x / progressBar.frame.size.width))
//                let targetTime : CMTime = CMTimeMake(value: Int64(total), timescale: 1)
//                player.seek(to: targetTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
//                AudioPlayManager.shared.updateMiniPlayerTime()
//            }
//        }
    }
    
    @objc func tapOnPlay(_ sender: UIButton) {
        // Get section index from button layer
        guard let sectionIndex = sender.layer.value(forKey: "Section") as? Int else { return }
        // Get key from history data
        let key = historyData.keys[historyData.index(historyData.startIndex, offsetBy: sectionIndex)]
        // Get cell data from history data
        guard let cellData = historyData[key]?[sender.tag] else { return }
        // Get current index from audio list
        guard let currentIndex = audioList.firstIndex(where: { $0.Id == cellData.Audio_story.Id }) else { return }
                
        if sender.isSelected {
            // Pause audio and update row
            if AudioPlayManager.shared.playerAV != nil {
                AudioPlayManager.shared.playPauseAudio(false, addToHistory: true)
                if audioTimer.isValid {
                    audioTimer.invalidate()
                }
                selectedIndex = -1
                selectedSection = -1
                self.tableView.reloadData()
                return
            }
        } else {
            // Check already audio is loaded
            if AudioPlayManager.shared.currentIndex == currentIndex && AudioPlayManager.shared.playerAV != nil {
                AudioPlayManager.shared.playPauseAudio(true)
                enableTimer()
                selectedIndex = sender.tag
                selectedSection = sectionIndex
                self.tableView.reloadData()
                return
            }
            
            // Set audio for audio play manager
            AudioPlayManager.shared.audioList = audioList
            
            // Set current audio index of audio play manager
            AudioPlayManager.shared.setAudioIndex(currentIndex, isNext: false)
            
            // Set audio history id
            AudioPlayManager.shared.audioHistoryId = cellData.Id
            
            // Check favourite audio list and set to audio play manager
            if !AudioPlayManager.shared.isHistory {
                // Enable isfavorite of audio player manager
                AudioPlayManager.shared.isHistory = true
                AudioPlayManager.shared.isFavourite = false
                AudioPlayManager.shared.isNonStop = false
            }
            
            // Set curret audio index of audio play manager
            self.initPlayerManager(sectionIndex, rowIndex: sender.tag, currentSecond: cellData.Time)
        }
    }
    
    private func enableTimer() {
        if audioTimer.isValid {
            audioTimer.invalidate()
        }
        audioTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(self.udpateTime), userInfo: nil, repeats: true)
        RunLoop.main.add(self.audioTimer, forMode: .default)
        audioTimer.fire()
    }
    
    // MARK: - Initialize audio play manager
    private func initPlayerManager(_ section: Int, rowIndex: Int, currentSecond: Int) {
        if let player = AudioPlayManager.shared.playerAV, player.isPlaying {
            // Pause current playing audio
            AudioPlayManager.shared.playPauseAudio(false)
            if audioTimer.isValid {
                audioTimer.invalidate()
            }
        }
        
        // Show progress bar
        Core.ShowProgress(self, detailLbl: "")
                    
        // Initialize audio play manager
        AudioPlayManager.shared.initPlayerManager(false, isNonStop: false, getMeters: false, isHistory: true) { [self] success in
            Core.HideProgress(self)
            
//            // Add mini player view in footer
//            if AudioPlayManager.shared.isMiniPlayerActive {
//                AudioPlayManager.shared.addMiniPlayer(self, bottomConstraint: self.containerBottomCons)
//            }
            // Play audio now
            if let player = AudioPlayManager.shared.playerAV {
                // Seek current playing audio
                player.seek(to: CMTimeMake(value: Int64(currentSecond * 1000), timescale: 1000))
            }
            enableTimer()
            AudioPlayManager.shared.playPauseAudio(true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                // For update row set selected index
                if let player = AudioPlayManager.shared.playerAV, player.isPlaying {
                    selectedIndex = rowIndex
                    selectedSection = section
                }
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func tapOnFav(_ sender: UIButton) {
        // Get section index from button layer
        if let sectionIndex = sender.layer.value(forKey: "Section") as? Int {
            // Get key from history data
            let key = historyData.keys[historyData.index(historyData.startIndex, offsetBy: sectionIndex)]
            // Get cell data from history data
            if let cellData = historyData[key]?[sender.tag] {
                // Check fav audio is added
                if !sender.isSelected {
                    // Add to favourite
                    self.addToFav(cellData.Audio_story.Id) { status in
                        if let st = status, st {
                            sender.isSelected = !sender.isSelected
                        }
                    }
                } else {
                    // Remove to favourite
                    self.removeFromFav(cellData.Audio_story.Id) { status in
                        if let st = status, st {
                            sender.isSelected = !sender.isSelected
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Audio playing completed
    @objc private func itemDidFinishedPlaying(_ notificaction: Notification) {
        playingCurrentAudio()
        // Scroll to perticuler row
        if selectedIndex >= 0 && selectedSection >= 0 {
            let indexPath = IndexPath(row: selectedIndex, section: selectedSection)
            self.tableView.reloadData()
            self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        } else {
            tableView.reloadData()
        }
        tableView.tableFooterView = UIView()
//        selectedIndex = -1
//        selectedSection = -1
//        tableView.reloadData()
//        if audioTimer.isValid {
//            audioTimer.invalidate()
//        }
//        if selectedIndex >= 0 {
//            let indexPath = IndexPath(row: selectedIndex, section: 0)
//            self.tableView.reloadData()
//            self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
//        } else {
//            tableView.reloadData()
//        }
    }
    
    // MARK: - Update time as per playing audio
    @objc func udpateTime() {
        if let player = AudioPlayManager.shared.playerAV, let currentItem = player.currentItem {
            DispatchQueue.main.async { [self] in
                // Get the current time in seconds
                let playhead = currentItem.currentTime().seconds
//                let duration = currentItem.duration.seconds
                
//                if !playhead.isNaN && !duration.isNaN  {
//                    // Set progres bar progress
//                    currentProgressBar.progress = Float(playhead / duration)
//                }
                // Get section index from button layer
                guard let sectionIndex = currentProgressBar.layer.value(forKey: "Section") as? Int else { return }
                // Get key from history data
                let key = historyData.keys[historyData.index(historyData.startIndex, offsetBy: sectionIndex)]
                if !playhead.isNaN {
                    historyData[key]?[currentProgressBar.tag].Time = Int(roundf(Float(playhead)))
                }
                self.tableView.reloadRows(at: [IndexPath(row: currentProgressBar.tag, section: sectionIndex)], with: .none)
            }
        }
    }
    
    private func playingCurrentAudio() {
        // Check mini player audio is playing or not
        if let player = AudioPlayManager.shared.playerAV, player.isPlaying {
            // Create private temp row and section index
            var sectioIdx = 0
            var rowIdx = -1
            for (_, histList) in historyData {
                for idx in 0..<histList.count {
                    if histList[idx].Audio_story.Id == AudioPlayManager.shared.currentAudio.Id {
                        // Set row index
                        rowIdx = idx
                        break
                    }
                }
                if rowIdx != -1 {
                    break
                }
                sectioIdx += 1
            }
            // Set row and section index
            selectedIndex = rowIdx
            selectedSection = sectioIdx
        }
    }
}

// MARK: - Get Data from server -
extension HistoryViewController {
    // Get audio history
    private func getHistory() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self, methodName: "getHistory")
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        HistoryAudioClient.get("1", limit: 10) { [self] response in
            showNoData = 1
            if let data = response {
                morePage = data.count > 0
                historyList = historyList + data
                
                // Set audio list from history data
                historyList.forEach { hist in
                    audioList.append(hist.Audio_story)
                }
                
                // Set history data from history list
                historyData = Dictionary(grouping: historyList, by: { $0.Updated_at })
                playingCurrentAudio()
            }
            // Scroll to perticuler row
            if selectedIndex >= 0 && selectedSection >= 0 {
                let indexPath = IndexPath(row: selectedIndex, section: selectedSection)
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
            } else {
                tableView.reloadData()
            }
            tableView.tableFooterView = UIView()
            // Check mini player audio is playing or not
            if let player = AudioPlayManager.shared.playerAV, player.isPlaying {
                enableTimer()
            }
            // Hide progress
            Core.HideProgress(self)
        }
    }
    
    // Add to favourite
    private func addToFav(_ audio_story_id: Int, completion: @escaping(Bool?) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        FavouriteAudioClient.add(FavouriteRequest(audio_story_id: audio_story_id)) { [self] status in
            Core.HideProgress(self)
            completion(status)
        }
    }
    
    // Remove from favourite
    private func removeFromFav(_ audio_story_id: Int, completion: @escaping(Bool?) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        FavouriteAudioClient.remove(FavouriteRequest(audio_story_id: audio_story_id)) { [self] status in
            Core.HideProgress(self)
            completion(status)
        }
    }
}

// MARK: - UITableViewDataSource -
extension HistoryViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return historyData.keys.count > 0 ? historyData.keys.count : showNoData
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if historyData.keys.count > 0 {
            let key = historyData.keys[historyData.index(historyData.startIndex, offsetBy: section)]
            return historyData[key]?.count ?? 0
        }
        return showNoData
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if historyData.keys.count <= 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataTableViewCell", for: indexPath) as? NoDataTableViewCell else { return UITableViewCell() }
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "audioCell", for: indexPath) as? AudioViewCell else { return UITableViewCell() }
        
        // Get key of current row using section
        let key = historyData.keys[historyData.index(historyData.startIndex, offsetBy: indexPath.section)]
        
        // Check audio is paying for current row
        let playIsSelected = indexPath.section == selectedSection && indexPath.row == selectedIndex
        
        // Set cell data
        if let cellData = historyData[key]?[indexPath.row] {
            // Set history image
            cell.profileImage.sd_setImage(with: URL(string: cellData.Audio_story.ImageUrl), placeholderImage: defaultImage, options: [], context: nil)
            
            // Set likes and duration
            cell.subTitleLabel.text = "\(cellData.Audio_story.Favorites_count) Likes | \(AudioPlayManager.getHoursMinutesSecondsFromString(seconds: Double(cellData.Time)))"
            
            // Set favourite button
            cell.favButton.isSelected = cellData.Audio_story.Is_favorite
            
            // Set progres bar progress
            cell.progressBar.progress = Float(Float(cellData.Time) / cellData.Audio_story.AudioDuration)
            
            // Set audio title
            cell.titleLabel.text = cellData.Audio_story.Title
            cell.titleLabel.textColor = .white
            if playIsSelected {
                cell.progressBar.tag = indexPath.row
                cell.progressBar.layer.setValue(indexPath.section, forKey: "Section")

                currentProgressBar = cell.progressBar
                // Set audio title playing audio
                let soundWave = Core.getImageString("wave")
                let titleAttText = NSMutableAttributedString(string: "\(cellData.Audio_story.Title)  ")
                titleAttText.append(soundWave)
                cell.titleLabel.attributedText = titleAttText
                cell.titleLabel.textColor = UIColor(displayP3Red: 213.0 / 255.0, green: 40.0 / 255.0, blue: 54.0 / 255.0, alpha: 1.0)
            }
        }
        if let image = cell.profileImage {
            image.cornerRadius = image.frame.size.height / 2.0
        }
        
        // Set play button index and function
        cell.playButton.tag = indexPath.row
        cell.playButton.layer.setValue(indexPath.section, forKey: "Section")
        cell.playButton.addTarget(self, action: #selector(tapOnPlay(_:)), for: .touchUpInside)
        cell.playButton.isSelected = playIsSelected

        // Set Favourite button index and function
        cell.favButton.tag = indexPath.row
        cell.favButton.layer.setValue(indexPath.section, forKey: "Section")
        cell.favButton.addTarget(self, action: #selector(tapOnFav(_:)), for: .touchUpInside)
        
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITableViewDelegate -
extension HistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return historyData.keys.count <= 0 ? 30 : 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Core.push(self, storyboard: Constants.Storyboard.audio, storyboardId: "NowPlayViewController")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return historyData.keys.count <= 0 ? 0 : 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if historyData.keys.count <= 0 {
            return UIView()
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell") as? AudioViewCell else { return UIView() }
        cell.titleLabel.layer.masksToBounds = true
        cell.titleLabel.layer.cornerRadius = cell.titleLabel.frame.size.height / 2.0
        cell.titleLabel.text = "  \(historyData.keys[historyData.index(historyData.startIndex, offsetBy: section)])  "
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if historyData.keys.count > 0 {
            // Get key of current row using section
            let key = historyData.keys[historyData.index(historyData.startIndex, offsetBy: indexPath.section)]
            if indexPath.section > 0, let historyListt = historyData[key], historyListt.count > 5, indexPath.section == historyListt.count - 1 && self.morePage {
                //last cell load more
                pageNumber += 1
                tableView.tableFooterView = footerView
                if let indicator = footerView.viewWithTag(10) as? UIActivityIndicatorView {
                    indicator.startAnimating()
                }
                DispatchQueue.global(qos: .background).async { DispatchQueue.main.async { self.getHistory() } }
            }
        }
        
    }
}


// MARK: - NoInternetDelegate -
extension HistoryViewController: NoInternetDelegate {
    func connectedToNetwork(_ methodName: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.perform(Selector((methodName)))
        }
    }
}
