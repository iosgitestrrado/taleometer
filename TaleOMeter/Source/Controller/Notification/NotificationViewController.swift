//
//  NotificationViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 01/12/22.
//

import UIKit

class NotificationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentController: CustomSegmentedControl!
    
    private var notifiTriviaList = [NotificationModel]()
    private var notifiTaleometerList = [NotificationModel]()
    
    private var footerView = UIView()
    private var morePage = true
    private var pageNumber = 1
    
    private var morePageTrivia = true
    private var pageNumberTrivia = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Core.initFooterView(self, footerView: &footerView)

        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "NoDataTableViewCell")
        
        self.segmentController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16.0)], for: .selected)
        self.segmentController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16.0)], for: .normal)
//        self.segmentController.layer.masksToBounds = true
//        self.segmentController.layer.cornerRadius = 25.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true, titleInLeft: true, backImage: true)
        getNotifications()
        addActivityLog()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        if isMovingFromParent {
//            self.sideMenuController!.toggleRightView(animated: false)
//        }
    }
    
    @IBAction func tapOnClearAll(_ sender: UIButton) {
//        if segmentController.selectedSegmentIndex
        let alert = UIAlertController(title: "Clear All", message: self.segmentController.selectedSegmentIndex == 0 ? "Are you sure want to clear all notifications of the trivia section?" : "Are you sure want to clear all notifications of the taleometer section?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.updateNotification(type: self.segmentController.selectedSegmentIndex == 0 ? "trivia" : "taleometer", isRead: false, showMessage: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive))
        self.present(alert, animated: true)
    }

    @IBAction func changeSegment(_ sender: UISegmentedControl) {
        self.tableView.reloadData()
    }
    
    @objc func tapOnCloseButton(_ sender: UIButton) {
        self.updateNotification(sender.tag, type: segmentController.selectedSegmentIndex == 0 ? "trivia" : "taleometer", isRead: false, showMessage: true)
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

extension NotificationViewController {
    // MARK: - Get Notification data
    @objc func getNotifications() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self, methodName: "getNotifications")
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        notifiTriviaList = [NotificationModel]()
        notifiTaleometerList = [NotificationModel]()
        OtherClient.getNotifications(1, limit: 20, noti_type: "") { [self] response in
            if let data = response, data.count > 0 {
                data.forEach { object in
                    if object.Notify_type.lowercased() == "trivia" {
                        notifiTriviaList.append(object)
                    } else {
                        notifiTaleometerList.append(object)
                    }
                }
            }
            self.tableView.reloadData()
            Core.HideProgress(self)
//            getTaleometerNotifications()
        }
    }
    
    @objc func getTriviaNotifications() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self, methodName: "getTaleometerNotifications")
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        
        OtherClient.getNotifications(pageNumberTrivia, limit: 20, noti_type: "trivia") { [self] response in
            if let data = response, data.count > 0 {
                morePageTrivia = true
                notifiTriviaList = pageNumberTrivia == 1 ? data : notifiTriviaList + data
            } else {
                morePageTrivia = false
            }
            self.tableView.reloadData()
            Core.HideProgress(self)
        }
    }
    
    @objc func getTaleometerNotifications() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self, methodName: "getTaleometerNotifications")
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        
        OtherClient.getNotifications(pageNumber, limit: 20, noti_type: "taleometer") { [self] response in
            if let data = response, data.count > 0 {
                morePage = true
                notifiTaleometerList = pageNumber == 1 ? data : notifiTaleometerList + data
            } else {
                morePage = false
            }
            self.tableView.reloadData()
            Core.HideProgress(self)
        }
    }
    
    @objc func updateNotification(_ id: Int = -1, type: String = "trivia", isRead: Bool = true, isProgresShow: Bool = true, showMessage: Bool = false) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self, methodName: "updateNotification")
            return
        }
        if isProgresShow {
            Core.ShowProgress(self, detailLbl: "")
        }
        OtherClient.updateNotification(NotificationUpdateRequest(type: isRead ? "read" : "clear", notification_id: id != -1 ? "\(id)" : "all", notify_type: type), showSuccMessage: showMessage) { status in
            if !isRead, let st = status, st {
                self.getNotifications()
            }
            if isProgresShow {
                Core.HideProgress(self)
            }
        }
    }
    
    // MARK: Add into activity log
    private func addActivityLog() {
        if !Reachability.isConnectedToNetwork() {
            return
        }
        DispatchQueue.global(qos: .background).async {
            ActivityClient.userActivityLog(UserActivityRequest(post_id: "", category_id: "", screen_name: Constants.ActivityScreenName.notification, type: Constants.ActivityType.story)) { status in
            }
        }
    }
}

extension NotificationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentController.selectedSegmentIndex == 0 {
            return notifiTriviaList.count > 0 ? notifiTriviaList.count : 1
        }
        return notifiTaleometerList.count > 0 ? notifiTaleometerList.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentController.selectedSegmentIndex == 0 {
            if self.notifiTriviaList.count <= 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataTableViewCell", for: indexPath) as? NoDataTableViewCell else { return UITableViewCell() }
                return cell
            }
            if let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier, for: indexPath) as? NotificationTableViewCell {
                cell.configure(notifiTriviaList[indexPath.row], target: self, selector: #selector(tapOnCloseButton(_:)))
                return cell
            }
        } else {
            if self.notifiTaleometerList.count <= 1 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataTableViewCell", for: indexPath) as? NoDataTableViewCell else { return UITableViewCell() }
                return cell
            }
            if let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier, for: indexPath) as? NotificationTableViewCell {
                cell.configure(notifiTaleometerList[indexPath.row], target: self, selector: #selector(tapOnCloseButton(_:)))
                return cell
            }
        }
        return UITableViewCell()
    }
}


extension NotificationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if segmentController.selectedSegmentIndex == 0 {
            return self.notifiTriviaList.count > 0 ? UITableView.automaticDimension : 30.0
        }
        return self.notifiTaleometerList.count > 0 ? UITableView.automaticDimension : 30.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if segmentController.selectedSegmentIndex == 0 {
            if notifiTriviaList.count > 5 && indexPath.row == notifiTriviaList.count - 1 && self.morePageTrivia {
                //last cell load more
                pageNumberTrivia += 1
                tableView.tableFooterView = footerView
                if let indicator = footerView.viewWithTag(10) as? UIActivityIndicatorView {
                    indicator.startAnimating()
                }
                DispatchQueue.global(qos: .background).async { DispatchQueue.main.async { self.getTriviaNotifications() } }
            }
        } else {
            if notifiTaleometerList.count > 5 && indexPath.row == notifiTaleometerList.count - 1 && self.morePage {
                //last cell load more
                pageNumber += 1
                tableView.tableFooterView = footerView
                if let indicator = footerView.viewWithTag(10) as? UIActivityIndicatorView {
                    indicator.startAnimating()
                }
                DispatchQueue.global(qos: .background).async { DispatchQueue.main.async { self.getTaleometerNotifications() } }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                self.updateNotification(self.segmentController.selectedSegmentIndex == 0 ? self.notifiTriviaList[indexPath.row].Id : self.notifiTaleometerList[indexPath.row].Id, type: self.segmentController.selectedSegmentIndex == 0 ? "trivia" : "taleometer", isProgresShow: false)
            }
        }
        
        if segmentController.selectedSegmentIndex == 0 {
            if notifiTriviaList.count > 0 &&  notifiTriviaList[indexPath.row].Target_page.lowercased() == "leaderboard" {
                if let myobject = UIStoryboard(name: Constants.Storyboard.trivia, bundle: nil).instantiateViewController(withIdentifier: "TRFeedViewController") as? TRFeedViewController {
                    if AudioPlayManager.shared.isNonStop {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "closeMiniPlayer"), object: nil)
                    }
                    myobject.categoryId = notifiTriviaList[indexPath.row].Target_page_id
                    self.navigationController?.pushViewController(myobject, animated: true)
                }
            } else if notifiTriviaList.count > 0 &&  notifiTriviaList[indexPath.row].Target_page_id != -1 && notifiTriviaList[indexPath.row].Target_page.lowercased() == "trivia" {
                if let myobject = UIStoryboard(name: Constants.Storyboard.trivia, bundle: nil).instantiateViewController(withIdentifier: LeaderboardViewController().className) as? LeaderboardViewController {
                    self.navigationController?.pushViewController(myobject, animated: true)
                }
            }
        } else {
            if notifiTaleometerList.count > 0 &&  notifiTaleometerList[indexPath.row].Target_page.lowercased() == "chat" {
                if let myobject = UIStoryboard(name: Constants.Storyboard.chat, bundle: nil).instantiateViewController(withIdentifier: ChatViewController().className) as? ChatViewController {
                    self.navigationController?.pushViewController(myobject, animated: true)
                }
            } else if notifiTaleometerList.count > 0 &&  notifiTaleometerList[indexPath.row].Target_page_id != -1, notifiTaleometerList[indexPath.row].Target_page.lowercased() == "audio_story" {
                if let myobject = UIStoryboard(name: Constants.Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "NowPlayViewController") as? NowPlayViewController {
                    if AudioPlayManager.shared.isNonStop {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "closeMiniPlayer"), object: nil)
                    }
                    myobject.isFromNotification = true
                    myobject.myAudioList = [notifiTaleometerList[indexPath.row].Audio_story]
                    myobject.currentAudioIndex = 0
                    AudioPlayManager.shared.audioList = [notifiTaleometerList[indexPath.row].Audio_story]
                    AudioPlayManager.shared.setAudioIndex(0, isNext: false)
                    self.navigationController?.pushViewController(myobject, animated: true)
                }
            }
        }
    }
}

// MARK: - NoInternetDelegate -
extension NotificationViewController: NoInternetDelegate {
    func connectedToNetwork(_ methodName: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.perform(Selector((methodName)))
        }
    }
}
