//
//  AudioListViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 22/02/22.
//

import UIKit

// MARK: - Protocol used for sending data back -
protocol AudioListViewDelegate: AnyObject {
    func changeIntoPlayingAudio(_ currentAudio: Audio)
}

class AudioListViewController: UITableViewController {

    // MARK: - Public Property -
    var parentConroller = UIViewController()
    var containerBottomCons = NSLayoutConstraint()
    var isFavourite = false
    var isAuthor = false
    var storyData = StoryModel()
    var isStroy = false
    var isPlot = false
    var isNarration = false
    var currentAudio = Audio()
    // Making this a weak variable, so that it won't create a strong reference cycle
    weak var delegate: AudioListViewDelegate? = nil
    
    // MARK: - Private Property -
    private var selectedIndex = -1
    private var highLightedLabel: UILabel?
    private var titleStr = "Asked The Mentor"
//    private var favAudioList = [Audio]()
    private var audioList = [Audio]()
    private var footerView = UIView()
    private var morePage = true
    private var pageNumber = 1
    private var showNoData = 0
    private var shuffle = 0

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "NoDataTableViewCell")
        Core.initFooterView(self, footerView: &footerView)
        if isFavourite {
            self.getFavourite()
        } else if isStroy {
            self.getStoryAudios()
        } else if isPlot {
            self.getPlotAudios()
        } else if isNarration {
            self.getNarrationAudios()
        }
        // Set notification center for audio playing completed
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishedPlaying), name: AudioPlayManager.finishNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playPauseAudio(_:)), name: AudioPlayManager.favPlayNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playPauseAudio(_:)), name: remoteCommandName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tapOnShuffled(_:)), name: Notification.Name(rawValue: "shuffleAudio"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tapOnPlayStoryAudio(_:)), name: Notification.Name(rawValue: "playStoryAudio"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: AudioPlayManager.favPlayNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: AudioPlayManager.finishNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: remoteCommandName, object: nil)
        NotificationCenter.default.removeObserver(self, name: remoteCommandName, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "shuffleAudio"), object: nil)
        if (isPlot || isStroy || isNarration), !self.isMovingFromParent, let del = self.delegate {
            del.changeIntoPlayingAudio(currentAudio)
        }
    }
    
    // MARK: - Initialize table footer view
    func initFooterView() {
        footerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: Double(self.view.frame.size.width), height: 40.0))
        let actind = UIActivityIndicatorView(style: .medium)
        actind.tag = 10
        actind.frame = CGRect(x: (self.view.frame.size.width / 2.0) - 10.0, y: 5.0, width: 20.0, height: 20.0)
        actind.hidesWhenStopped = true
        footerView.addSubview(actind)
        footerView.isHidden = false
    }
    
    // MARK: - Play story audio -
    @objc private func tapOnPlayStoryAudio(_ notification: Notification) {
        if audioList.count <= 0 {
            return
        }
        if let playNow = notification.userInfo?["PlayNow"] as? Bool {
            setAudioListPM(0)
            if playNow {
                playAudioNow(0)
            } else {
                if AudioPlayManager.shared.playerAV != nil {
                    AudioPlayManager.shared.playPauseAudio(false, addToHistory: true)
                    selectedIndex = -1
                    self.tableView.reloadData()
                    return
                }
            }
        }
    }
    
    // MARK: - Shuffle Audio -
    @objc private func tapOnShuffled(_ notification: Notification) {
        shuffle = 1
        morePage = true
        pageNumber = 1
        showNoData = 0
        audioList = [Audio]()
        if isStroy {
            self.getStoryAudios()
        } else if isPlot {
            self.getPlotAudios()
        } else if isNarration {
            self.getNarrationAudios()
        }
    }
    
    // MARK: - Play Pause current audio -
    @objc private func playPauseAudio(_ notification: Notification) {
        if (notification.userInfo?["isPlaying"] as? Bool) != nil {
            if let player = AudioPlayManager.shared.playerAV {
                if !player.isPlaying {
                    if !AudioPlayManager.shared.isFavourite {
                        selectedIndex = -2
                        if let selectedAudio = audioList.firstIndex(where: { $0.Id == AudioPlayManager.shared.currentAudio.Id }) {
                            selectedIndex = selectedAudio
                        }
                    }
                    if selectedIndex >= -1 {
                        let indexPath = IndexPath(row: !AudioPlayManager.shared.isFavourite ? selectedIndex : AudioPlayManager.shared.currentIndex, section: 0)
                        selectedIndex = indexPath.row
                        self.tableView.reloadData()
                        self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
                    }
                } else {
                    selectedIndex = -1
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Click on play pause buttion
    @objc private func tapOnPlay(_ sender: UIButton) {
        setAudioListPM(sender.tag)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "mainScreenPlay"), object: nil, userInfo: ["IsSelected" : !sender.isSelected])
        
        // Check current selected index
        if sender.isSelected {
            // Pause audio and update row
            if AudioPlayManager.shared.playerAV != nil {
                AudioPlayManager.shared.playPauseAudio(false, addToHistory: true)
                selectedIndex = -1
                self.tableView.reloadData()
                return
            }
        } else {
            playAudioNow(sender.tag)
        }
    }
    
    // MARK: - Set audio list in play manager
    private func setAudioListPM(_ currentIndex: Int) {
        // Check favourite audio list and set to audio play manager
        if !AudioPlayManager.shared.isFavourite {
            // Set current playing audio in temp variable
            let tempAudio = AudioPlayManager.shared.currentAudio
            
            // Enable isfavorite of audio player manager
            AudioPlayManager.shared.isFavourite = true
            AudioPlayManager.shared.isNonStop = false
            
            // Set audio for audio play manager
            AudioPlayManager.shared.audioList = [Audio]()
            audioList.forEach { fav in
                AudioPlayManager.shared.audioList?.append(fav)
            }
            
            // Set current audio index of audio play manager
            AudioPlayManager.shared.setAudioIndex(currentIndex, isNext: false)
            if tempAudio.Id != AudioPlayManager.shared.currentAudio.Id {
                self.initPlayerManager()
            }
        }
    }
    
    // MARK: - Play audio now
    private func playAudioNow(_ currentIndex: Int) {
        // Check already audio is loaded
        if AudioPlayManager.shared.currentIndex == currentIndex && AudioPlayManager.shared.playerAV != nil {
            AudioPlayManager.shared.playPauseAudio(true)
            selectedIndex = currentIndex
            self.tableView.reloadData()
            return
        }
        // Set audio for audio play manager
        AudioPlayManager.shared.audioList = [Audio]()
        audioList.forEach { fav in
            AudioPlayManager.shared.audioList?.append(fav)
        }
        
        // Set curret audio index of audio play manager
        AudioPlayManager.shared.setAudioIndex(currentIndex, isNext: false)
        self.initPlayerManager()
    }
    
    // MARK: - Initialize audio play manager
    private func initPlayerManager() {
        if let player = AudioPlayManager.shared.playerAV, player.isPlaying {
            // Pause current playing audio
            AudioPlayManager.shared.playPauseAudio(false)
        }
        
        // Show progress bar
        Core.ShowProgress(parentConroller, detailLbl: "")
                    
        // Initialize audio play manager
        AudioPlayManager.shared.initPlayerManager(true, isNonStop: false, getMeters: false) { [self] success in
            Core.HideProgress(parentConroller)
            
            // Add mini player view in footer
            if AudioPlayManager.shared.isMiniPlayerActive {
                AudioPlayManager.shared.addMiniPlayer(parentConroller, bottomConstraint: self.containerBottomCons)
            }
            // Play audio now
            AudioPlayManager.shared.playPauseAudio(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                // For update row set selected index
                if let player = AudioPlayManager.shared.playerAV, player.isPlaying {
                    selectedIndex = AudioPlayManager.shared.currentIndex
                }
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Audio playing completed
    @objc private func itemDidFinishedPlaying(_ notificaction: Notification) {
        selectedIndex = -1
        if let isNextPrev = notificaction.userInfo?["isNextPrev"] as? Bool, isNextPrev {
            if let selectedAudio = audioList.firstIndex(where: { $0.Id == AudioPlayManager.shared.currentAudio.Id }) {
                    selectedIndex = selectedAudio
            }
        } else {
            if let audioList2 = AudioPlayManager.shared.audioList, let selectedAudio = audioList.firstIndex(where: { $0.Id == audioList2[AudioPlayManager.shared.nextIndex].Id }) {
                    selectedIndex = selectedAudio
            }
        }
        if selectedIndex >= 0 {
            let indexPath = IndexPath(row: selectedIndex, section: 0)
            self.tableView.reloadData()
            self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        } else {
            tableView.reloadData()
        }
    }
    
    // MARK: - Add to favourite and remove from favourite
    @objc private func tapOnFav(_ sender: UIButton) {
        if isFavourite {
            self.removeFromFav(audioList[sender.tag].Id) { [self] status in
                if let st = status, st {
                    sender.isSelected = !sender.isSelected
                    audioList.remove(at: sender.tag)
                    if AudioPlayManager.shared.isFavourite, AudioPlayManager.shared.currentIndex == sender.tag {
                        AudioPlayManager.shared.removeMiniPlayer()
                        guard let player = AudioPlayManager.shared.playerAV else { return }
                        if player.isPlaying {
                            AudioPlayManager.shared.playPauseAudio(false, addToHistory: true)
                        }
                        selectedIndex = -1
                        if currentAudio.Id == audioList[sender.tag].Id {
                            currentAudio.Is_favorite = false
                        }
                    }
                    tableView.reloadData()
                }
            }
        } else {
            if !sender.isSelected {
                self.addToFav(audioList[sender.tag].Id) { [self] status in
                    if currentAudio.Id == audioList[sender.tag].Id {
                        currentAudio.Is_favorite = true
                    }
                    sender.isSelected = !sender.isSelected
                }
            } else if sender.isSelected {
                self.removeFromFav(audioList[sender.tag].Id) { [self] status in
                    sender.isSelected = !sender.isSelected
                    if currentAudio.Id == audioList[sender.tag].Id {
                        currentAudio.Is_favorite = false
                    }
                }
            }
        }
    }
}

// MARK: - Favourite API Calls
extension AudioListViewController {
    
    // Get Favourite audios
    private func getFavourite() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(parentConroller)
            return
        }
        Core.ShowProgress(parentConroller, detailLbl: "Getting Favourite Audio...")
        FavouriteAudioClient.get("\(pageNumber)") { [self] result in
            showNoData = 1
            if let response = result {
                morePage = response.count > 0
                audioList = audioList + response
                if AudioPlayManager.shared.isMiniPlayerActive, let player = AudioPlayManager.shared.playerAV, player.isPlaying, let selectedAudio = audioList.firstIndex(where: { $0.Id == AudioPlayManager.shared.currentAudio.Id }) {
                    selectedIndex = selectedAudio
                }
            }
            if selectedIndex >= 0 {
                let indexPath = IndexPath(row: selectedIndex, section: 0)
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
            } else {
                tableView.reloadData()
            }
            tableView.tableFooterView = UIView()
            Core.HideProgress(parentConroller)
        }
    }
    
    // Add to favourite
    private func addToFav(_ audio_story_id: Int, completion: @escaping(Bool?) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(parentConroller)
            return
        }
        Core.ShowProgress(parentConroller, detailLbl: "")
        FavouriteAudioClient.add(FavouriteRequest(audio_story_id: audio_story_id)) { [self] status in
            Core.HideProgress(parentConroller)
            completion(status)
        }
    }
    
    // Remove from favourite
    private func removeFromFav(_ audio_story_id: Int, completion: @escaping(Bool?) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(parentConroller)
            return
        }
        Core.ShowProgress(parentConroller, detailLbl: "")
        FavouriteAudioClient.remove(FavouriteRequest(audio_story_id: audio_story_id)) { [self] status in
            Core.HideProgress(parentConroller)
            completion(status)
        }
    }
}

// MARK: - Story, Plot and Narration API Calls
extension AudioListViewController {
    private func getStoryAudios() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(parentConroller)
            return
        }
        Core.ShowProgress(parentConroller, detailLbl: "Getting Audios...")
        AudioClient.getAudiosByStory(StoryRequest(story_id: storyData.Id, shuffle: shuffle, page: "\(pageNumber)", limit: 10)) { [self] response in
            showNoData = 1
            if let data = response, data.count > 0 {
                morePage = data.count > 0
                audioList = audioList + data
                if AudioPlayManager.shared.isMiniPlayerActive, let player = AudioPlayManager.shared.playerAV, player.isPlaying, let selectedAudio = audioList.firstIndex(where: { $0.Id == AudioPlayManager.shared.currentAudio.Id }) {
                    selectedIndex = selectedAudio
                }
                if selectedIndex >= 0 {
                    let indexPath = IndexPath(row: selectedIndex, section: 0)
                    self.tableView.reloadData()
                    self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
                } else {
                    tableView.reloadData()
                }
                tableView.tableFooterView = UIView()
                NotificationCenter.default.post(name: Notification.Name(rawValue: "mainScreenPlay"), object: nil, userInfo: ["TotalStories" : audioList.count])
            }
            Core.HideProgress(parentConroller)
        }
    }
    
    private func getPlotAudios() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(parentConroller)
            return
        }
        Core.ShowProgress(parentConroller, detailLbl: "Getting Audios...")
        AudioClient.getAudiosByPlot(PlotRequest(plot_id: storyData.Id, shuffle: shuffle, page: "\(pageNumber)", limit: 10)) { [self] response in
            showNoData = 1
            if let data = response, data.count > 0 {
                morePage = data.count > 0
                audioList = audioList + data
                if AudioPlayManager.shared.isMiniPlayerActive, let player = AudioPlayManager.shared.playerAV, player.isPlaying, let selectedAudio = audioList.firstIndex(where: { $0.Id == AudioPlayManager.shared.currentAudio.Id }) {
                    selectedIndex = selectedAudio
                }
                if selectedIndex >= 0 {
                    let indexPath = IndexPath(row: selectedIndex, section: 0)
                    self.tableView.reloadData()
                    self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
                } else {
                    tableView.reloadData()
                }
                tableView.tableFooterView = UIView()
                NotificationCenter.default.post(name: Notification.Name(rawValue: "mainScreenPlay"), object: nil, userInfo: ["TotalStories" : audioList.count])
            }
            Core.HideProgress(parentConroller)
        }
    }
    
    private func getNarrationAudios() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(parentConroller)
            return
        }
        Core.ShowProgress(parentConroller, detailLbl: "Getting Audios...")
        AudioClient.getAudiosByNarration(NarrationRequest(narration_id: storyData.Id, shuffle: shuffle, page: "\(pageNumber)", limit: 10)) { [self] response in
            showNoData = 1
            if let data = response, data.count > 0 {
                morePage = data.count > 0
                audioList = audioList + data
                
                if AudioPlayManager.shared.isMiniPlayerActive, let player = AudioPlayManager.shared.playerAV, player.isPlaying, let selectedAudio = audioList.firstIndex(where: { $0.Id == AudioPlayManager.shared.currentAudio.Id }) {
                    selectedIndex = selectedAudio
                }
                if selectedIndex >= 0 {
                    let indexPath = IndexPath(row: selectedIndex, section: 0)
                    self.tableView.reloadData()
                    self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
                } else {
                    tableView.reloadData()
                }
                tableView.tableFooterView = UIView()
                NotificationCenter.default.post(name: Notification.Name(rawValue: "mainScreenPlay"), object: nil, userInfo: ["TotalStories" : audioList.count])
            }
            Core.HideProgress(parentConroller)
        }
    }
}

// MARK: - UITableViewDataSource -
extension AudioListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.audioList.count > 0 ? self.audioList.count : showNoData
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.audioList.count <= 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataTableViewCell", for: indexPath) as? NoDataTableViewCell else { return UITableViewCell() }
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "audioCell", for: indexPath) as? AudioViewCell else { return UITableViewCell() }
        let audioData = audioList[indexPath.row]
        cell.configureCell(audioData, likesCount: 0, duration: 0, isFavourite: isFavourite, row: indexPath.row, selectedIndex: selectedIndex, target: self, selectors: [#selector(tapOnPlay(_:)), #selector(tapOnFav(_:))])
        return cell
    }
}

// MARK: - UITableViewDelegate -
extension AudioListViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.audioList.count <= 0 ? 30 : 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if audioList.count > 5 && indexPath.row == audioList.count - 1 && self.morePage {
            //last cell load more
            pageNumber += 1
            tableView.tableFooterView = footerView
            if let indicator = footerView.viewWithTag(10) as? UIActivityIndicatorView {
                indicator.startAnimating()
            }
            DispatchQueue.global(qos: .background).async { DispatchQueue.main.async { self.getFavourite() } }
        }
    }
}
