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
        getTriviaNotifications()
        addActivityLog()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            self.sideMenuController!.toggleRightView(animated: false)
        }
    }
    
    @IBAction func tapOnClearAll(_ sender: UIButton) {
        
    }

    @IBAction func changeSegment(_ sender: UISegmentedControl) {
        self.tableView.reloadData()
    }
    
    @objc func tapOnCloseButton(_ sender: UIButton) {
        
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
    @objc func getTriviaNotifications() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self, methodName: "getTriviaNotifications")
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        
        OtherClient.getNotifications(pageNumberTrivia, limit: 20, noti_type: "trivia") { [self] response in
            if let data = response, data.count > 0 {
                morePageTrivia = data.count > 0
                notifiTriviaList = pageNumberTrivia == 1 ? data : notifiTriviaList + data
            }
            getTaleometerNotifications()
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
                morePage = data.count > 0
                notifiTaleometerList = pageNumber == 1 ? data : notifiTaleometerList + data
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
                cell.configure(notifiTriviaList[indexPath.row], row: indexPath.row, target: self, selector: #selector(tapOnCloseButton(_:)))
                return cell
            }
        } else {
            if self.notifiTaleometerList.count <= 1 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataTableViewCell", for: indexPath) as? NoDataTableViewCell else { return UITableViewCell() }
                return cell
            }
            if let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier, for: indexPath) as? NotificationTableViewCell {
                cell.configure(notifiTaleometerList[indexPath.row], row: indexPath.row, target: self, selector: #selector(tapOnCloseButton(_:)))
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
}

// MARK: - NoInternetDelegate -
extension NotificationViewController: NoInternetDelegate {
    func connectedToNetwork(_ methodName: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.perform(Selector((methodName)))
        }
    }
}
