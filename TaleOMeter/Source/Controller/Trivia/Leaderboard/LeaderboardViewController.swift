//
//  LeaderboardViewController.swift
//  TaleOMeter
//
//  Created by Eppancy on 05/07/22.
//

import UIKit

class LeaderboardViewController: UIViewController {

    // MARK: - Weak Properties -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leaderImg: UIImageView!
    @IBOutlet weak var noDatalabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var triviaScoreLbl: UILabel!
    @IBOutlet weak var rankTotalUserLbl: UILabel!

    
    private var leaderboardList = [LeaderboardModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "NoDataTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true, titleInLeft: true, backImage: true, bigfont: true)
        getLeaderboardData()
        addActivityLog()
    }
    
    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
        if let textContainer = window.viewWithTag(9998) {
            textContainer.removeFromSuperview()
        }
        self.sideMenuController!.toggleRightView(animated: true)
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

extension LeaderboardViewController {
    // MARK: - Get trivia posts
    @objc func getLeaderboardData() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self, methodName: "getLeaderboardData")
            return
        }
//        noDatalabel.isHidden = true
        Core.ShowProgress(self, detailLbl: "")
        TriviaClient.getLeaderboards { [self] response in
            if let data = response {
                leaderboardList = data.TopTen
                self.profileImage.sd_setImage(with: URL(string: data.CurrentUser.Avatar), placeholderImage: Login.defaultProfileImage, context: nil)
                self.nameLabel.text = data.CurrentUser.Name
                self.triviaScoreLbl.text = "\(data.CurrentUser.Points)"
                self.rankTotalUserLbl.text = "\(data.CurrentUser.Rank)/\(data.CurrentUser.TotalUsers)"
//                self.leaderImg.sd_setImage(with: URL(string: data[0].Image), placeholderImage: defaultImage)
//                noDatalabel.isHidden = true
//                leaderImg.isHidden = false
            }
//            noDatalabel.isHidden = leaderboardList.count > 0
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
            ActivityClient.userActivityLog(UserActivityRequest(post_id: "", category_id: "", screen_name: Constants.ActivityScreenName.leaderboard, type: Constants.ActivityType.trivia)) { status in
            }
        }
    }
    
}

// MARK: - UITableViewDataSource -
extension LeaderboardViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboardList.count > 0 ? leaderboardList.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.leaderboardList.count <= 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataTableViewCell", for: indexPath) as? NoDataTableViewCell else { return UITableViewCell() }
            return cell
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardCell", for: indexPath) as? LeaderBoardTableViewCell {
            cell.configure(leaderboardList[indexPath.row], row: indexPath.row)
            return cell
        }
        return UITableViewCell()
//        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardCell", for: indexPath)
//        if let imageView = cell.viewWithTag(1) as? UIImageView {
//            imageView.sd_setImage(with: URL(string: leaderboardList[indexPath.row].Image), placeholderImage: defaultImage)
//        }
//        return cell
//        if let cell = tableView.dequeueReusableCell(withIdentifier: FeedCellIdentifier.question, for: indexPath) as? FeedCellView {
//            cell.configureLeaderboard(with: leaderboardList[indexPath.row])
//            return cell
//        }
    }
}

// MARK: - UITableViewDelegate -
extension LeaderboardViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.leaderboardList.count > 0 ? UITableView.automaticDimension : 30.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
}


// MARK: - NoInternetDelegate -
extension LeaderboardViewController: NoInternetDelegate {
    func connectedToNetwork(_ methodName: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.perform(Selector((methodName)))
        }
    }
}
