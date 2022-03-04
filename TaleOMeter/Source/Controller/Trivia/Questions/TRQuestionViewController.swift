//
//  TRQuestionViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 03/03/22.
//

import UIKit
import AVFoundation
import AVKit

class TRQuestionViewController: UIViewController {
    
    // MARK: - Weak Properties -
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Private Properties -
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true, titleInLeft: false)
    }
    
    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        self.sideMenuController!.toggleRightView(animated: true)
    }
  
    @objc private func tapOnPlayVideo(_ sender: UIButton) {
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: "imageCell", for: IndexPath(row: sender.tag, section: 0)) as? QuestionCellView {
            guard let videoURL = URL(string: "https://www.youtube.com/watch?v=9xwazD5SyVg") else { return }
            
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            playerViewController.view.frame = cell.videoView.bounds
            playerViewController.player?.play()
            cell.videoView.addSubview(playerViewController.view)
            
//            let player = AVPlayer(url: videoURL)
//            let playerLayer = AVPlayerLayer(player: player)
//            playerLayer.frame = cell.videoView.bounds
//            cell.videoView.layer.addSublayer(playerLayer)
//            player.play()
        }
    }
}

// MARK: - UITableViewDataSource -
extension TRQuestionViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as? QuestionCellView else { return UITableViewCell() }
       
        cell.coverImage.layer.cornerRadius = 20
        cell.coverImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        cell.bottomView.layer.cornerRadius = 20
        cell.bottomView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        cell.videoButton.tag = indexPath.row
        cell.videoButton.addTarget(self, action: #selector(tapOnPlayVideo(_:)), for: .touchUpInside)
        
        if indexPath.row == 0, let videoURL = URL(string: "https://v.pinimg.com/videos/720p/77/4f/21/774f219598dde62c33389469f5c1b5d1.mp4") {
            let avPlayer = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.delegate = self
            DispatchQueue.main.async {
                playerViewController.player = avPlayer
                playerViewController.view.frame = cell.videoView.bounds
                cell.videoView.addSubview(playerViewController.view)
                //playerViewController.player?.play()
                playerViewController.showsPlaybackControls = true
                //playerViewController.view.didMoveToSuperview()
                //playerViewController.didMove(toParent: self)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                    playerViewController.player?.play()
//                }
            }
        }
        cell.selectionStyle = .none
        return cell
    }
        
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        guard let videoCell = cell as? QuestionCellView else { return }
//
//        videoCell.videoView.player?.pause()
//        videoCell.videoView.player = nil
    }
}

// MARK: - UITableViewDelegate -
extension TRQuestionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 286
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}


// MARK: - AVPlayerViewControllerDelegate -
extension TRQuestionViewController: AVPlayerViewControllerDelegate {
    
    
}
