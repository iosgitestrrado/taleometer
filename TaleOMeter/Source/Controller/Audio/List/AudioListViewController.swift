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

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isNonStop {
            NotificationCenter.default.addObserver(self, selector: #selector(nextAudioPlay(_:)), name: Notification.Name(rawValue: "nextAudio"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playCurrentAudio(_:)), name: Notification.Name(rawValue: "playAudio"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(pauseCurrentAudio(_:)), name: Notification.Name(rawValue: "pauseAudio"), object: nil)
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
    }
    
    private func highlightedRow(_ rowIndex: Int) {
        
    }
        
    // MARK: - UITableViewDataSource -
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "audioCell", for: indexPath) as? AudioViewCell else { return UITableViewCell() }
        
        cell.configureCell(self.titleStr, isNonStop: isNonStop, isFavourite: isFavourite, row: indexPath.row, selectedIndex: selectedIndex, target: self, selectors: [#selector(tapOnPlay(_:)), #selector(tapOnFav(_:))])
        return cell
    }
    
    // MARK: - UITableViewDelegate -
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
