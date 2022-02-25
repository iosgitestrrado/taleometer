//
//  AudioListViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 22/02/22.
//

import UIKit

class AudioListViewController: UITableViewController {

    // MARK: - Public Property -
    public var isFavourite = false
    public var isNonStop = false
    
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
        cell.isSelected = indexPath.row == selectedIndex
        if let image = cell.imageView {
            image.cornerRadius = image.frame.size.height / 2.0
        }
        cell.playButton.isHidden = isNonStop
        cell.favButton.isHidden = isNonStop
        if let titleLbl = cell.titleLabel {
            if cell.isSelected {
                let soundWave = Core.getImageString("wave")
                let titleAttText = NSMutableAttributedString(string: "\(self.titleStr)  ")
                titleAttText.append(soundWave)
                titleLbl.attributedText = titleAttText
                titleLbl.textColor = UIColor(displayP3Red: 213.0 / 255.0, green: 40.0 / 255.0, blue: 54.0 / 255.0, alpha: 1.0)
            } else {
                titleLbl.text = titleStr
                titleLbl.textColor = .white
            }
        }
        if !isNonStop {
            cell.playButton.tag = indexPath.row
            cell.playButton.isSelected = cell.isSelected
            cell.playButton.addTarget(self, action: #selector(tapOnPlay(_:)), for: .touchUpInside)
            cell.favButton.addTarget(self, action: #selector(tapOnFav(_:)), for: .touchUpInside)
            if isFavourite {
                cell.favButton.isSelected = isFavourite
            }
        }
        cell.selectionStyle = .none
        return cell
    }
    
    // MARK: - UITableViewDelegate -
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
