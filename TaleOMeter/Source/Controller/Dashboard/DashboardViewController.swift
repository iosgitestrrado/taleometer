//
//  DashboardViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 12/02/22.
//

import UIKit
import LGSideMenuController
import AVFoundation

class DashboardViewController: UIViewController {

    // MARK: - Weak Property -
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerBottomCons: NSLayoutConstraint!
    @IBOutlet weak var surpriseButton: UIButton!
    @IBOutlet weak var nonStopBtn: UIButton!
    @IBOutlet weak var chatBarButton: BadgedButtonItem!
    @IBOutlet weak var notiBarButton: BadgedButtonItem!

    // MARK: - Private Property -
    var segmentController = SegmentViewController()

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.surpriseButton.isHidden = true
        chatBarButton.setup(image: UIImage(named: "msg"))
        notiBarButton.setup(image: UIImage(named: "noti"))

        chatBarButton.tapAction = {
            if let myobject = UIStoryboard(name: Constants.Storyboard.chat, bundle: nil).instantiateViewController(withIdentifier: ChatViewController().className) as? ChatViewController {
                self.navigationController?.pushViewController(myobject, animated: true)
            }
        }
        notiBarButton.tapAction = {
            if let myobject = UIStoryboard(name: Constants.Storyboard.other, bundle: nil).instantiateViewController(withIdentifier: NotificationViewController().className) as? NotificationViewController {
                self.navigationController?.pushViewController(myobject, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true)
        self.navigationItem.hidesBackButton = true
        
        //Add footer view and manager current view frame
        FooterManager.addFooter(self, bottomConstraint: self.containerBottomCons)
        if AudioPlayManager.shared.isMiniPlayerActive {
            AudioPlayManager.shared.addMiniPlayer(self, bottomConstraint: self.containerBottomCons)
        }
        getNotificationCount()
        self.nonStopBtn.isSelected = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let heightt = self.view.safeAreaInsets.bottom == 0 ? -34.0 : self.view.safeAreaInsets.bottom
        self.containerView.frame.size.width = CGFloat((350.0 * UIScreen.main.bounds.width) / 390.0)
        self.containerView.frame.size.height = CGFloat(((469.0 + heightt) * UIScreen.main.bounds.height) / 844.0)
        segmentController.parentFrame = self.containerView.frame    
    
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
        if let textContainer = window.viewWithTag(9998) {
            textContainer.removeFromSuperview()
        }
    }
    
    private func getNotificationCount() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self, methodName: "getNotificationCount")
            //completionHandler?()
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        AudioClient.getNotificationCount { chatCount, notificationCount in
            if let chat_c = chatCount, chat_c > 0 {
                self.chatBarButton.setBadge(with: chat_c)
            }
            if let noti_c = notificationCount, noti_c > 0 {
                self.notiBarButton.setBadge(with: noti_c)
            }
            Core.HideProgress(self)
        }
    }
    
    // MARK: Close Audio Mini player
    @objc private func closeMiniPlayer(_ notification: NSNotification) {
        UIView.transition(with: self.nonStopBtn as UIView, duration: 0.75, options: .transitionCrossDissolve) {
            self.nonStopBtn.isSelected = false
        }
    }
    
    // MARK: - Side Menu button action -
    @IBAction func ClickOnTopbarItem(_ sender: UIBarButtonItem) {
        if sender.tag == 0 { // Menu
            self.sideMenuController!.toggleRightView(animated: true)
        }
    }
    
    // MARK: - tap on non stop button
    @IBAction func tapOnNonStop(_ sender: UIButton) {
        if UserDefaults.standard.bool(forKey: Constants.UserDefault.IsLogin) {
            UIView.transition(with: self.nonStopBtn as UIView, duration: 0.75, options: .transitionCrossDissolve) {
                self.nonStopBtn.isSelected = !self.nonStopBtn.isSelected
            } completion: { [self] isDone in
                if self.nonStopBtn.isSelected {
                    Core.push(self, storyboard: Constants.Storyboard.audio, storyboardId: "NonStopViewController")
                } else {
                    AudioPlayManager.shared.isNonStop = !self.nonStopBtn.isSelected
                    AudioPlayManager.shared.isMiniPlayerActive = !self.nonStopBtn.isSelected
                    AudioPlayManager.shared.removeMiniPlayer()
                    guard let player = AudioPlayManager.shared.playerAV else { return }
                    if player.isPlaying {
                        AudioPlayManager.shared.playPauseAudio(false)
                    }
                }
            }
        } else {
            Core.push(self, storyboard: Constants.Storyboard.auth, storyboardId: "LoginViewController")
        }
    }
    
    // MARK: Click on surprise button
    @IBAction func tapOnSurprise(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.UserDefault.IsLogin) {
            Core.ShowProgress(self, detailLbl: "")
            AudioClient.getSurpriseAudio(AudioRequest(page: "all", limit: 100)) { response in
                if let data = response, data.count > 0 {
                    if let myobject = UIStoryboard(name: Constants.Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "NowPlayViewController") as? NowPlayViewController {
                        if AudioPlayManager.shared.isNonStop {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "closeMiniPlayer"), object: nil)
                        }
                        myobject.myAudioList = data
                        myobject.currentAudioIndex = 0
                        AudioPlayManager.shared.audioList = data
                        AudioPlayManager.shared.setAudioIndex(0, isNext: false)
                        self.navigationController?.pushViewController(myobject, animated: true)
                    }
                }
                Core.HideProgress(self)
            }
        } else {
            Core.push(self, storyboard: Constants.Storyboard.auth, storyboardId: "LoginViewController")
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segmentview", let segVC = segue.destination as? SegmentViewController {
            segVC.parentController = self
            self.containerView.frame.size.width = CGFloat((350.0 * UIScreen.main.bounds.width) / 390.0)
            self.containerView.frame.size.height = CGFloat((503.0 * UIScreen.main.bounds.height) / 844.0)
            segVC.parentFrame = self.containerView.frame
            segmentController = segVC
        }
    }
}

// MARK: - PromptViewDelegate -
extension DashboardViewController: PromptViewDelegate {
    func didActionOnPromptButton(_ tag: Int) {
        AudioPlayManager.shared.didActionOnPromptButton(tag)
    }
}

// MARK: - NoInternetDelegate -
extension DashboardViewController: NoInternetDelegate {
    func connectedToNetwork(_ methodName: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.perform(Selector((methodName)))
        }
    }
}
