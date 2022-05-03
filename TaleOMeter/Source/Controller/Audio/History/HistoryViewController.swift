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
    private var historyData = [HistoryObjects]()
    private var selectedIndex = -1
    private var selectedSection = -1
    private var currentProgressBar = UIProgressView()
    
    private var footerView = UIView()
    private var morePage = true
    private var pageNumber = 1
    private var showNoData = 0
    private var audioTimer = Timer()
    
    private struct HistoryObjects {
        var sectionName = String()
        var sectionObjects = [History]()
    }
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "NoDataTableViewCell")
        Core.initFooterView(self, footerView: &footerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true)
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishedPlaying), name: AudioPlayManager.finishNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            self.sideMenuController!.toggleRightView(animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        morePage = true
        pageNumber = 1
        showNoData = 0
        historyList = [History]()
        getHistory()
    }

    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        self.sideMenuController!.toggleRightView(animated: true)
    }
    
    // MARK: - Play pause video -
    @objc func tapOnPlay(_ sender: UIButton) {
        // Get section index from button layer
        guard let sectionIndex = sender.layer.value(forKey: "Section") as? Int else { return }
        // Get key from history data
       // let key = historyData.keys[historyData.index(historyData.startIndex, offsetBy: sectionIndex)]
        // Get cell data from history data
        let cellData = historyData[sectionIndex].sectionObjects[sender.tag]       // Get current index from audio list
        guard let currentIndex = audioList.firstIndex(where: { $0.Id == cellData.Audio_story.Id }) else { return }
        if let myobject = UIStoryboard(name: Constants.Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "NowPlayViewController") as? NowPlayViewController {
//                if let audioUrl = URL(string: audioList[indexPath.row].File) {
//                    let fileName = NSString(string: audioUrl.lastPathComponent)
//                    if !supportedAudioExtenstion.contains(fileName.pathExtension.lowercased()) {
//                        Toast.show("Audio File \"\(fileName.pathExtension)\" is not supported!")
//                        return
//                    }
//                }
            if AudioPlayManager.shared.isNonStop {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "closeMiniPlayer"), object: nil)
            }
            if AudioPlayManager.shared.currentIndex == currentIndex {
                myobject.existingAudio = true
                myobject.isPlaying = !sender.isSelected
            } else {
                myobject.myAudioList = audioList
                myobject.currentAudioIndex = currentIndex
                myobject.currentPlayDuration = cellData.Time
                AudioPlayManager.shared.audioList = audioList
                AudioPlayManager.shared.setAudioIndex(currentIndex, isNext: false)
            }
            self.navigationController?.pushViewController(myobject, animated: true)
        }
        /*
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
        }*/
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
            // Get cell data from history data
            let cellData = historyData[sectionIndex].sectionObjects[sender.tag]
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
    
    // MARK: - Audio playing completed
    @objc private func itemDidFinishedPlaying(_ notificaction: Notification) {
        selectedIndex = -1
        selectedSection = -1
        tableView.reloadData()
//        playingCurrentAudio()
//        // Scroll to perticuler row
//        if selectedIndex >= 0 && selectedSection >= 0 {
//            let indexPath = IndexPath(row: selectedIndex, section: selectedSection)
//            self.tableView.reloadData()
//            self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
//        } else {
//
//        }
        
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
                if !playhead.isNaN && currentProgressBar.tag > historyData[sectionIndex].sectionObjects.count {
                    historyData[sectionIndex].sectionObjects[currentProgressBar.tag].Time = Int(roundf(Float(playhead)))
                }
                self.tableView.reloadRows(at: [IndexPath(row: currentProgressBar.tag, section: sectionIndex)], with: .none)
            }
        }
    }
    
    private func playingCurrentAudio() {
        selectedIndex = -1
        selectedSection = -1
        // Check mini player audio is playing or not
        if let player = AudioPlayManager.shared.playerAV, player.isPlaying {
            // Create private temp row and section index
            var sectioIdx = 0
            var rowIdx = -1
            for histList in historyData {
                for idx in 0..<histList.sectionObjects.count {
                    if histList.sectionObjects[idx].Audio_story.Id == AudioPlayManager.shared.currentAudio.Id {
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
    private func getHistory(_ showProgress: Bool = true) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self, methodName: "getHistory")
            return
        }
        if showProgress {
            Core.ShowProgress(self, detailLbl: "")
        }
        
        HistoryAudioClient.get("\(pageNumber)", limit: 10) { [self] response in
            showNoData = 1
            if let data = response {
                morePage = data.count > 0
                historyList = pageNumber == 0 ? data : historyList + data
                
                // Set audio list from history data
                historyList.forEach { hist in
                    audioList.append(hist.Audio_story)
                }
               // historyList = historyList.sorted(by: { $0.Updated_at_full.compare($1.Updated_at_full) == .orderedDescending })
                // Set history data from history list
                let historyData1 = Dictionary(grouping: historyList, by: { $0.Updated_at })
                
                historyData = sortWithKeys(historyData1)
//                for his in historyData {
//                    his.value.sorted(by: { $0.Updated_at > $1.Updated_at})
//                }
                playingCurrentAudio()
            }
        
            // Scroll to perticuler row
            DispatchQueue.main.async {
                self.tableView.reloadData()
                if pageNumber == 1 && selectedIndex >= 0 && selectedSection >= 0 {
                    let indexPath = IndexPath(row: selectedIndex, section: selectedSection)
                    self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
                }
            }
            tableView.tableFooterView = UIView()
            // Check mini player audio is playing or not
            if let player = AudioPlayManager.shared.playerAV, player.isPlaying {
                enableTimer()
            }
            if showProgress {
                // Hide progress
                Core.HideProgress(self)
            }
        }
    }
    
    // Sort dictionary by key
    private func sortWithKeys(_ dict: [String: [History]]) -> [HistoryObjects] {

        let df = DateFormatter()
        df.dateFormat = Constants.DateFormate.app
        let sorted = dict.map{(df.date(from: $0.key)!, [$0.key:$0.value])}
            .sorted{$0.0 > $1.0}
            .map{$1}
        var newDict = [HistoryObjects]()
        df.dateFormat = Constants.DateFormate.appWithTime
        for sortedDic in sorted {
            for var st in sortedDic {
                st.value = st.value.sorted(by: { obj1, obj2 in
                    return df.date(from: obj1.Updated_at_full)?.compare(df.date(from: obj2.Updated_at_full) ?? Date()) == .orderedDescending
                })
                newDict.append(HistoryObjects(sectionName: st.key, sectionObjects: st.value))
            }
        }
        return newDict
    }
    
    // Add to favourite
    private func addToFav(_ audio_story_id: Int, completion: @escaping(Bool?) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        FavouriteAudioClient.add(FavouriteRequest(audio_story_id: audio_story_id)) { [self] status in
            if let st = status, st {
                AudioPlayManager.shared.currentAudio.Is_favorite = true
                if AudioPlayManager.shared.audioList != nil {
                    AudioPlayManager.shared.audioList![AudioPlayManager.shared.currentIndex].Is_favorite = true
                }
            }
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
            if let st = status, st {
                AudioPlayManager.shared.currentAudio.Is_favorite = false
                if AudioPlayManager.shared.audioList != nil {
                    AudioPlayManager.shared.audioList![AudioPlayManager.shared.currentIndex].Is_favorite = false
                }
            }
            Core.HideProgress(self)
            completion(status)
        }
    }
}

// MARK: - UITableViewDataSource -
extension HistoryViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return historyData.count > 0 ? historyData.count : showNoData
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyData.count > section ? historyData[section].sectionObjects.count : showNoData
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if historyData.count <= 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataTableViewCell", for: indexPath) as? NoDataTableViewCell else { return UITableViewCell() }
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "audioCell", for: indexPath) as? AudioViewCell else { return UITableViewCell() }
        
        // Check audio is paying for current row
        let playIsSelected = indexPath.section == selectedSection && indexPath.row == selectedIndex
        
        // Set cell data
        let cellData = historyData[indexPath.section].sectionObjects[indexPath.row]
        // Set history image
        cell.profileImage.sd_setImage(with: URL(string: cellData.Audio_story.ImageUrl), placeholderImage: defaultImage, options: [], context: nil)
        
        // Set likes and duration
        cell.subTitleLabel.text = "\(cellData.Audio_story.Favorites_count) Likes | \(AudioPlayManager.getHoursMinutesSecondsFromString(seconds: Double(cellData.Time)))"
        
        // Set favourite button
        cell.favButton.isSelected = cellData.Audio_story.Is_favorite
        
        // Set progres bar progress
        cell.progressBar.progress = cellData.Audio_story.Duration > 0 ? Float(cellData.Time / cellData.Audio_story.Duration) : 0.0
        
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
        return historyData.count <= 0 ? 30 : 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Core.push(self, storyboard: Constants.Storyboard.audio, storyboardId: "NowPlayViewController")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return historyData.count <= 0 ? 0 : 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if historyData.count <= 0 {
            return UIView()
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell") as? AudioViewCell else { return UIView() }
        cell.titleLabel.layer.masksToBounds = true
        cell.titleLabel.layer.cornerRadius = cell.titleLabel.frame.size.height / 2.0
        cell.titleLabel.text = "  \(historyData[section].sectionName)  "
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Get key of current row using section
        if historyData.count > 0, indexPath.section == historyData.count - 1, indexPath.row == historyData[indexPath.section].sectionObjects.count - 1 && self.morePage {
            //last cell load more
            pageNumber += 1
            tableView.tableFooterView = footerView
            if let indicator = footerView.viewWithTag(10) as? UIActivityIndicatorView {
                indicator.startAnimating()
            }
            DispatchQueue.global(qos: .background).async { DispatchQueue.main.async { self.getHistory(false) } }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Get cell data from history data
        let cellData = historyData[indexPath.section].sectionObjects[indexPath.row]
        // Get current index from audio list
        guard let currentIndex = audioList.firstIndex(where: { $0.Id == cellData.Audio_story.Id }) else { return }
        if let myobject = UIStoryboard(name: Constants.Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "NowPlayViewController") as? NowPlayViewController {
//                if let audioUrl = URL(string: audioList[indexPath.row].File) {
//                    let fileName = NSString(string: audioUrl.lastPathComponent)
//                    if !supportedAudioExtenstion.contains(fileName.pathExtension.lowercased()) {
//                        Toast.show("Audio File \"\(fileName.pathExtension)\" is not supported!")
//                        return
//                    }
//                }
            if AudioPlayManager.shared.isNonStop {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "closeMiniPlayer"), object: nil)
            }
            myobject.myAudioList = audioList
            myobject.currentAudioIndex = currentIndex
            AudioPlayManager.shared.audioList = audioList
            AudioPlayManager.shared.setAudioIndex(currentIndex, isNext: false)
            self.navigationController?.pushViewController(myobject, animated: true)
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
