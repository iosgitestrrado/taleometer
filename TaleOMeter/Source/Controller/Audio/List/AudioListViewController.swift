//
//  AudioListViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 22/02/22.
//

import UIKit

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
    
    // MARK: - Private Property -
    private var selectedIndex = -1
    private var highLightedLabel: UILabel?
    private var titleStr = "Asked The Mentor"
//    private var favAudioList = [Audio]()
    private var audioList = [Audio]()
    private var footerView = UIView()
    private var morePage = true
    private var pageNumber = 1
    private var showNoData = false

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "NoDataTableViewCell")
        self.initFooterView()
        if isFavourite {
            self.getFavourite()
        }
        if isFavourite {
            // Set notification center for audio playing completed
            NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishedPlaying), name: AudioPlayManager.finishNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playPauseAudio(_:)), name: AudioPlayManager.favPlayNotification, object: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    // MARK: - Play Pause current audio -
    @objc private func playPauseAudio(_ notification: Notification) {
        if let isPlaying = notification.userInfo?["isPlaying"] as? Bool {
            if !AudioPlayManager.shared.isFavourite {
                selectedIndex = -2
                if let selectedAudio = audioList.firstIndex(where: { $0.Id == AudioPlayManager.shared.audio.Id }) {
                    selectedIndex = selectedAudio
                }
            }
            if selectedIndex >= -1 {
                if isPlaying {
                    selectedIndex = -1
                    self.tableView.reloadData()
                } else if selectedIndex >= 0 {
                    let indexPath = IndexPath(row: !AudioPlayManager.shared.isFavourite ? selectedIndex : AudioPlayManager.shared.currentAudio, section: 0)
                    selectedIndex = indexPath.row
                    self.tableView.reloadData()
                    self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
                }
            }
        }
    }
    
    // MARK: - Click on play pause buttion
    @objc private func tapOnPlay(_ sender: UIButton) {
        // Check favourite audio list and set to audio play manager
        if !AudioPlayManager.shared.isFavourite {
            // Set current playing audio in temp variable
            let tempAudio = AudioPlayManager.shared.audio
            
            // Enable isfavorite of audio player manager
            AudioPlayManager.shared.isFavourite = true
            AudioPlayManager.shared.isNonStop = false
            
            // Set audio for audio play manager
            AudioPlayManager.shared.audioList = [Audio]()
            audioList.forEach { fav in
                AudioPlayManager.shared.audioList?.append(fav)
            }
            
            // Set current audio index of audio play manager
            AudioPlayManager.shared.setAudioIndex(sender.tag, isNext: false)
            if tempAudio.Id != AudioPlayManager.shared.audio.Id {
                self.initPlayerManager()
            }
        }
        // Check current selected index
        if sender.isSelected {
            // Pause audio and update row
            if AudioPlayManager.shared.playerAV != nil {
                AudioPlayManager.shared.playPauseAudio(false)
                selectedIndex = -1
                self.tableView.reloadData()
                return
            }
        } else {
            // Check already audio is alread loaded
            if AudioPlayManager.shared.currentAudio == sender.tag && AudioPlayManager.shared.playerAV != nil {
                AudioPlayManager.shared.playPauseAudio(true)
                selectedIndex = sender.tag
                self.tableView.reloadData()
                return
            }
            // Set audio for audio play manager
            AudioPlayManager.shared.audioList = [Audio]()
            audioList.forEach { fav in
                AudioPlayManager.shared.audioList?.append(fav)
            }
            
            // Set curret audio index of audio play manager
            AudioPlayManager.shared.setAudioIndex(sender.tag, isNext: false)
            self.initPlayerManager()
        }
    }
    
    // MARK: - Initialize audio play manager
    private func initPlayerManager() {
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
            
            // For update row set selected index
            if let player = AudioPlayManager.shared.playerAV, player.isPlaying {
                selectedIndex = AudioPlayManager.shared.currentAudio
            }
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Audio playing completed
    @objc private func itemDidFinishedPlaying(_ notificaction: Notification) {
        selectedIndex = -1
        if let isNextPrev = notificaction.userInfo?["isNextPrev"] as? Bool, isNextPrev {
            if let selectedAudio = audioList.firstIndex(where: { $0.Id == AudioPlayManager.shared.audio.Id }) {
                    selectedIndex = selectedAudio
            }
        } else {
            if let audioList = AudioPlayManager.shared.audioList, let selectedAudio = audioList.firstIndex(where: { $0.Id == audioList[AudioPlayManager.shared.nextAudio].Id }) {
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
        sender.isSelected = !sender.isSelected
        if isFavourite {
            self.removeFromFav(audioList[sender.tag].Id) { [self] status in
                if let st = status, st {
                    audioList.remove(at: sender.tag)
                    tableView.reloadData()
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
            Toast.show()
            return
        }
        Core.ShowProgress(self, detailLbl: "Getting Favourite Audio...")
        FavouriteAudioClient.get("\(pageNumber)") { [self] result in
            if let response = result {
                morePage = response.count > 0
                audioList = audioList + response
                if AudioPlayManager.shared.isMiniPlayerActive, let player = AudioPlayManager.shared.playerAV, player.isPlaying, let selectedAudio = audioList.firstIndex(where: { $0.Id == AudioPlayManager.shared.audio.Id }) {
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
            }
            Core.HideProgress(self)
        }
    }
    
    // Add to favourite
    private func addToFav(_ audio_story_id: Int, completion: @escaping(Bool?) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Toast.show()
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        FavouriteAudioClient.add(FavouriteRequest(audio_story_id: audio_story_id)) { status in
            Core.HideProgress(self)
            completion(status)
        }
    }
    
    // Remove from favourite
    private func removeFromFav(_ audio_story_id: Int, completion: @escaping(Bool?) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            Toast.show()
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        FavouriteAudioClient.remove(FavouriteRequest(audio_story_id: audio_story_id)) { status in
            Core.HideProgress(self)
            completion(status)
        }
    }
}

// MARK: - Story, Plot and Narration API Calls
extension AudioListViewController {
    private func getStoryAudios() {
        
    }
    
    private func getPlotAudios() {
        if !Reachability.isConnectedToNetwork() {
            Toast.show()
            return
        }
        AudioClient.getAudiosByPlot(PlotRequest(plot_id: storyData.Id, page: "\(pageNumber)")) { [self] response in
            if let data = response, data.count > 0 {
                morePage = data.count > 0
                audioList = audioList + data
                tableView.reloadData()
                tableView.tableFooterView = UIView()
            }
        }
    }
    
    private func getNarrationAudios() {
        
    }
}

// MARK: - UITableViewDataSource -
extension AudioListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.audioList.count > 0 ? self.audioList.count : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.audioList.count <= 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataTableViewCell", for: indexPath) as? NoDataTableViewCell else { return UITableViewCell() }
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "audioCell", for: indexPath) as? AudioViewCell else { return UITableViewCell() }
        var audioData = Audio()
        if isFavourite {
            audioData = audioList[indexPath.row]
        } else {
            audioData = audioList[indexPath.row]
        }
        cell.configureCell(audioData.Title, audioImage: audioData.Image, likesCount: 0, duration: 0, isFavourite: isFavourite, row: indexPath.row, selectedIndex: selectedIndex, target: self, selectors: [#selector(tapOnPlay(_:)), #selector(tapOnFav(_:))])
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
