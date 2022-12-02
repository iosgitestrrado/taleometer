//
//  NotificationViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 01/12/22.
//

import UIKit

class NotificationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    private var notifiTriviaList = [NotificationModel]()
    private var notifiTaleometerList = [NotificationModel]()

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
        getNotifications()
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
    @objc func getNotifications() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self, methodName: "getNotifications")
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        OtherClient.getNotifications { response in
            if let data = response, data.count > 0 {
                data.forEach { object in
                    if object.Post_id == -1 {
                        self.notifiTaleometerList.append(object)
                    } else {
                        self.notifiTriviaList.append(object)
                    }
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
}

// MARK: - NoInternetDelegate -
extension NotificationViewController: NoInternetDelegate {
    func connectedToNetwork(_ methodName: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.perform(Selector((methodName)))
        }
    }
}
