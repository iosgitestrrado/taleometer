//
//  FAQViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 02/12/22.
//

import UIKit
import SoundWave
import CoreMedia
import AVFoundation

class FAQViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private struct SectionData {
        var isOpen = Bool()
        var numberOfRows = Int()
        var item = FAQModel()
    }
    private var faqSectionList = [SectionData]()
    private var playerAV: AVPlayer?
    private var audioFileUrl = ""
    private var visulizationView = AudioVisualizationView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "NoDataTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true, titleInLeft: true, backImage: true)
        getFAQData()
        addActivityLog()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            self.sideMenuController!.toggleRightView(animated: false)
        }
    }
    
    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        self.sideMenuController!.toggleRightView(animated: true)
    }
    
    @objc func tapOnSectionHeader(gestureView: UITapGestureRecognizer) {
        let indexPath = IndexPath(item: 0, section: gestureView.view!.tag)
        for item in 0..<self.faqSectionList.count {
            if indexPath.section != item {
                self.faqSectionList[item].isOpen = false
            }
        }
        self.tableView.reloadData()
        self.faqSectionList[indexPath.section].isOpen = !self.faqSectionList[indexPath.section].isOpen
        self.tableView.reloadSections(NSIndexSet(index: indexPath.section) as IndexSet, with: .automatic)
        self.perform(#selector(reloadTableView), with: nil, afterDelay: 0.3)
    }
    
    @objc func reloadTableView () {
        self.tableView.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension FAQViewController {
    // MARK: - Get FAQ data
    @objc func getFAQData() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self, methodName: "getFAQData")
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        faqSectionList = [SectionData]()
        OtherClient.getFAQ { response in
            if let data = response, data.count > 0 {
                data.forEach { object in
                    self.faqSectionList.append(SectionData(isOpen: false, numberOfRows: !object.Answer_audio.isEmpty && !object.Answer_eng.isEmpty ? 2 : 1, item: object))
                }
            }
            self.tableView.reloadData()
            Core.HideProgress(self)
        }
    }
    
    // MARK: Add into activity log
    private func addActivityLog() {
        if !Reachability.isConnectedToNetwork() {
            return
        }
        DispatchQueue.global(qos: .background).async {
            ActivityClient.userActivityLog(UserActivityRequest(post_id: "", category_id: "", screen_name: Constants.ActivityScreenName.faq, type: Constants.ActivityType.story)) { status in
            }
        }
    }
}

extension FAQViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.faqSectionList.count > 0 ? faqSectionList.count : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.faqSectionList[section].isOpen ? self.faqSectionList[section].numberOfRows : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0, self.faqSectionList[indexPath.section].numberOfRows == 2, let cell = tableView.dequeueReusableCell(withIdentifier: FAQTableViewCell.audioIdentifier, for: indexPath) as? FAQTableViewCell {
            if cell.playPauseButton != nil && !self.faqSectionList[indexPath.section].item.Answer_audio.isEmpty {
                cell.playPauseButton.isSelected = false
                audioFileUrl = self.faqSectionList[indexPath.section].item.Answer_audio
                cell.playPauseButton.addTarget(self, action: #selector(tapOnPlayPauseButton(_:)), for: .touchUpInside)
                self.visulizationView = cell.visualizationWave
                DispatchQueue.main.async {
                    self.visulizationView.reset()
                    // Initialize audio play in audio player manager
                    Core.ShowProgress(self, detailLbl: "Loading Audio waves")
                    self.initPlayerManager { result in
                        // Config audio in current view
                        self.configureAudio(result)
                        Core.HideProgress(self)
                    }
                }
            }
            return cell
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: FAQTableViewCell.contentIdentifier, for: indexPath) as? FAQTableViewCell {
            cell.configureContent(self.faqSectionList[indexPath.section].item)
           return cell
        }
        return UITableViewCell()
    }
}

extension FAQViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.faqSectionList.count <= 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataTableViewCell") as? NoDataTableViewCell else { return UITableViewCell() }
            return cell
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: FAQTableViewCell.sectionIdentifier) as? FAQTableViewCell {
            
            cell.configureSection(self.faqSectionList[section].item, isExpanded: self.faqSectionList[section].isOpen)
            if !self.faqSectionList[section].isOpen, playerAV != nil {
                playerAV?.pause()
            }
            cell.tag = section
            let headerTapped: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapOnSectionHeader(gestureView:)))
            headerTapped.view?.tag = section
            cell.addGestureRecognizer(headerTapped)
            return cell
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.faqSectionList.count > 0 ? UITableView.automaticDimension : 30.0
    }
}

// MARK: - Audio player
extension FAQViewController {
    
    @objc func tapOnPlayPauseButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected { // Play  now
            if playerAV != nil {
                self.playPauseAudio(true)
            } else {
                self.visulizationView.reset()
                Core.ShowProgress(self, detailLbl: "Streaming Audio")
                
                // Initialize audio play in audio player manager
                self.initPlayerManager { result in
                    // Config audio in current view
                    self.configureAudio(result)
                    self.playPauseAudio(true)

                    // Hide progress
                    Core.HideProgress(self)
                }
            }
        } else { // Pause now
            self.playPauseAudio(false)
        }
    }
    
    private func configureAudio(_ result: [Float]) {
        DispatchQueue.main.async { [self] in
            // Reset visulization wave
            self.visulizationView.stop()
            self.visulizationView.reset()
            if let player = playerAV {
                // Setup mereting levels of visulationview
                self.visulizationView.meteringLevels = result
                self.visulizationView.setNeedsDisplay()
                self.visulizationView.playChronometer = nil
                
                // Get audio duration and set in private variable
                if let duration = player.currentItem?.asset.duration {
                    // Totalvidio duration
                    let totalTimeDuration = Float(CMTimeGetSeconds(duration))
                
                    self.visulizationView.setplayChronometer(for: TimeInterval(totalTimeDuration))
                }
            }
        }
    }
    
    // MARK: - Configure audio as per pass url -
    public func initPlayerManager(_ completionHandler: @escaping(_ success: [Float]) -> ()) {
        
        guard let audioUrl = URL(string: audioFileUrl) else { return }

        // then lets create your document folder url
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        // lets create your destination file url
        var destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
       
        // if audio file is not supported change to mp3
        let fileName = NSString(string: destinationUrl.lastPathComponent)
        if !supportedAudioExtenstion.contains(fileName.pathExtension.lowercased()) {
            destinationUrl = destinationUrl.deletingPathExtension().appendingPathExtension("mp3")
        }
        
        var audioURL = URL(string: "")
        // to check if it exists before downloading it
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            audioURL = destinationUrl
            configureAudio(audioURL) { result in
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
                    configureAudio(audioURL) { result in
                        completionHandler(result)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
//                    Toast.show(error.localizedDescription)
                }
            }).resume()
        }
    }
    
    // MARK: - Configure audio file -
    func configureAudio(_ audioURL: URL?, completionHandler: @escaping(_ success: [Float]) -> ()) {
        // Check URL exists
        guard let url = audioURL else {
            Toast.show("No audio found!")
            return
        }
        // Initialize player with item additional url
        let playerItem = AVPlayerItem(url: url)
        
        // Inititialize Player
        self.playerAV = AVPlayer(playerItem: playerItem)
        
        // Set notification for audio finish
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
                        
        // Get audio meter and seton the variable
        AudioPlayManager.getAudioMeters(url, forChannel: 0) { success in
            completionHandler(success)
        }
    }
    
    // MARK: - When audio completed call function -
    @objc private func itemDidFinishPlaying(notification: NSNotification) {
        //if let player = playerAV, player.isPlaying {
        if let player = playerAV {
            player.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: 1000))
        }
    }
    
    // MARK: - Handle play pause audio
    private func playPauseAudio(_ playing: Bool) {
        guard let player = playerAV else { return }
        if playing {
            player.play()
            if let duration = player.currentItem?.asset.duration {
                // Totalvidio duration
                let totalTimeDuration = Float(CMTimeGetSeconds(duration))
                self.visulizationView.play(for: TimeInterval(totalTimeDuration))
            }
        } else {
            player.pause()
            visulizationView.pause()
        }
    }
}

// MARK: - NoInternetDelegate -
extension FAQViewController: NoInternetDelegate {
    func connectedToNetwork(_ methodName: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.perform(Selector((methodName)))
        }
    }
}


// MARK: - PromptViewDelegate -
extension FAQViewController: PromptViewDelegate {
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
    }
}
