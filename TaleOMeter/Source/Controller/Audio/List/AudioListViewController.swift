//
//  AudioListViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 22/02/22.
//

import UIKit

class AudioListViewController: UITableViewController {

    // MARK: - Public Property -
    var isFavourite = false
    var isNonStop = false
    
    // MARK: - Public Property -
    private var selectedIndex = -1
    private var highLightedLabel: UILabel?
    private var titleStr = "Asked The Mentor"
    private var currentAudioIdx = 0
    fileprivate var favAudioList = [Favourite]()

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "NoDataTableViewCell")
        if isFavourite {
            self.getFavourite()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isNonStop {
            NotificationCenter.default.addObserver(self, selector: #selector(nextAudioPlay(_:)), name: Notification.Name(rawValue: "nextAudio"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playCurrentAudio(_:)), name: Notification.Name(rawValue: "playAudio"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(pauseCurrentAudio(_:)), name: Notification.Name(rawValue: "pauseAudio"), object: nil)
        }
    }
    
    // MARK: - Get Favourite audios
    private func getFavourite() {
        Core.ShowProgress(self, detailLbl: "Getting Favourite Audio...")
        FavouriteAudioClient.get(1) { [self] result in
            if let response = result {
                favAudioList = response
                self.tableView.reloadData()
            }
            Core.HideProgress(self)
        }
    }
    
    @objc private func playCurrentAudio(_ notification: Notification) {
        if selectedIndex == currentAudioIdx {
            let indexPath = IndexPath(row: selectedIndex, section: 0)
            selectedIndex = -1
            self.tableView.reloadRows(at: [indexPath], with: .none)
        } else {
            let indexPath = IndexPath(row: currentAudioIdx, section: 0)
            selectedIndex = indexPath.row
            self.tableView.reloadData()
            self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        }
    }
    
    @objc private func pauseCurrentAudio(_ notification: Notification) {
        if selectedIndex <= 0 {
            return
        }
        let indexPath = IndexPath(row: selectedIndex, section: 0)
        selectedIndex = -1
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    @objc private func nextAudioPlay(_ notification: Notification) {
        currentAudioIdx += 1
        if currentAudioIdx > 19 {
            currentAudioIdx = 0
        }
    }
    
    @objc private func tapOnPlay(_ sender: UIButton) {
        if selectedIndex == sender.tag {
            let indexPath = IndexPath(row: selectedIndex, section: 0)
            selectedIndex = -1
            self.tableView.reloadRows(at: [indexPath], with: .none)
        } else {
            let indexPath = IndexPath(row: sender.tag, section: 0)
            selectedIndex = indexPath.row
            self.tableView.reloadData()
        }
    }
    
    @objc private func tapOnFav(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if isFavourite {
            self.removeFromFav(favAudioList[sender.tag].Audio_story_id) { [self] status in
                if let st = status, st {
                    favAudioList.remove(at: sender.tag)
                    tableView.reloadData()
                }
            }
        }
    }
    
    private func highlightedRow(_ rowIndex: Int) {
        
    }
        
    // MARK: - UITableViewDataSource -
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFavourite ? (self.favAudioList.count > 0 ? self.favAudioList.count : 1) : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isFavourite && self.favAudioList.count <= 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataTableViewCell", for: indexPath) as? NoDataTableViewCell else { return UITableViewCell() }
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "audioCell", for: indexPath) as? AudioViewCell else { return UITableViewCell() }
        let favourite = favAudioList[indexPath.row].Audio_story
        cell.configureCell(favourite.Title, audioImage: favourite.Image, likesCount: 0, duration: 0, isNonStop: isNonStop, isFavourite: isFavourite, row: indexPath.row, selectedIndex: selectedIndex, target: self, selectors: [#selector(tapOnPlay(_:)), #selector(tapOnFav(_:))])
        return cell
    }
    
    // MARK: - UITableViewDelegate -
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  isFavourite && self.favAudioList.count <= 0 ? 30 : 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension AudioListViewController {
    // Add to favourite
    private func addToFav(_ audio_story_id: Int, completion: @escaping(Bool?) -> Void) {
        Core.ShowProgress(self, detailLbl: "")
        FavouriteAudioClient.add(FavouriteRequest(audio_story_id: audio_story_id)) { status in
            Core.HideProgress(self)
            completion(status)
        }
    }
    
    // Remove from favourite
    private func removeFromFav(_ audio_story_id: Int, completion: @escaping(Bool?) -> Void) {
        Core.ShowProgress(self, detailLbl: "")
        FavouriteAudioClient.remove(FavouriteRequest(audio_story_id: audio_story_id)) { status in
            Core.HideProgress(self)
            completion(status)
        }
    }
}
