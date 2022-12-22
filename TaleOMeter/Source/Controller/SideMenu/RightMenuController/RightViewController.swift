//
//  RightViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 12/02/22.
//

import UIKit
import LinkPresentation

class RightViewController: UIViewController {
    
    // MARK: - Weak Property -
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Privare Property -
    private let cellProfileIdentifier = "profileCell"
    private let cellIdentifier = "cell"
    private let tableViewInset: CGFloat = 44.0 * 2.0
    private let cellHeight: CGFloat = 44.0
    private let cellProfileHeight: CGFloat = 153.0
    
    private enum SideViewCellItem: Equatable {
        case profile
        case triviaQuiz
        case leaderboard
//        case triviaComments
        case shareStory
        case history
        case preference
        case aboutUs
        case feedback
        case logout
        case appVersion
        case favorite
        case notification
        case fAQ
        case tutorial
        case chat

        var description: String {
            switch self {
            case .profile:
                return "My Account"
            case .triviaQuiz:
                return "Trivia"
            case .leaderboard:
                return "Trivia Leaderboard"
//            case .triviaComments:
//                return "Trivia Comments"
            case .shareStory:
                return "Share your Story"
            case .history:
                return "History"
            case .preference:
                return "Preference"
            case .aboutUs:
                return "About Us"
            case .favorite:
                return "Favourites"
            case .feedback:
                return "Reach Us"
            case .logout:
                return "Log Out"
            case .appVersion:
                return "V"
            case .notification:
                return "Notifications"
            case .fAQ:
                return "FAQ"
            case .tutorial:
                return "Tutorial"
            case .chat:
                return "Message"
            }
        }
        
        var storyboardId: String {
            switch self {
            case .profile:
                return Constants.Storyboard.auth
            case .leaderboard/*, .triviaComments*/:
                return Constants.Storyboard.trivia
            case .shareStory, .preference, .aboutUs, .feedback, .notification, .fAQ:
                return Constants.Storyboard.other
            case .history, .favorite:
                return Constants.Storyboard.audio
            case .logout:
                return Constants.Storyboard.auth
            case .tutorial:
                return Constants.Storyboard.launch
            case .chat:
                return Constants.Storyboard.chat
            case .triviaQuiz:
                return Constants.Storyboard.dashboard
            case .appVersion:
                return ""
            }
        }
        
        var controllerName: String {
            switch self {
            case .profile:
                return ProfileViewController().className
            case .triviaQuiz:
                return DashboardViewController().className
            case .leaderboard:
                return LeaderboardViewController().className
//            case .triviaComments:
//                return TRFeedViewController().className
            case .shareStory:
                return MainUserStoryVC().className
            case .history:
                return HistoryViewController().className
            case .preference:
                return SettingViewController().className
            case .aboutUs:
                return AboutUsViewController().className
            case .feedback:
                return FeedbackViewController().className
            case .logout:
                return LoginViewController().className
            case .favorite:
                return FavouriteViewController().className
            case .notification:
                return NotificationViewController().className
            case .fAQ:
                return FAQViewController().className
            case .tutorial:
                return LaunchViewController().className
            case .chat:
                return ChatViewController().className
            case .appVersion:
                return ""
            }
        }
    }
    
    private var sections: [[SideViewCellItem]] = [
        [.profile/*, .chat*/, .triviaQuiz, .leaderboard, .favorite/*, .triviaComments*/, .shareStory, .history, .fAQ, .tutorial, .aboutUs, .feedback, .logout, .appVersion]
    ]
    
    private let triviaSections: [[SideViewCellItem]] = [
        [.profile, .profile, .leaderboard, .preference, .aboutUs, .feedback, .logout, .appVersion]
    ]
    
    private var profileData: ProfileData?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let pfData = Login.getProfileData() {
            profileData = pfData
        }
        if isOnlyTrivia {
            sections = triviaSections
        }
    }
    
    @objc private func updateUserData(_ notification: Notification) {
        if let pfData = Login.getProfileData() {
            profileData = pfData
        }
        if isOnlyTrivia {
            sections = triviaSections
        }
        self.tableView.reloadData()
    }

    // MARK: - Status Bar -
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    @IBAction func tapOnInvite(_ sender: UIButton) {
//        if let shareImg = UIImage(named: "shareimg.jpeg") {
//            Core.shareImageViaWhatsapp(image: shareImg, onViewController: self)
//        }
        
        if let navCont = sideMenuController?.rootViewController as? UINavigationController, let url = URL(string: "https://apps.apple.com/us/app/taleometer/id1621063908"), let shareImg = UIImage(named: "shareimg.jpeg") {
            let text = "Time to relax, refresh and reset with Tale’o’meter trivia - The audio OTT (Original Tamil Tales).\n\nSignup for FREE. \(url)\n\nLet’s take the daily break we deserve. I play this daily as \(profileData?.Fname ?? "Guest")"
            Core.share(with: navCont, image: shareImg, content: text) { status in
                if let st = status, st {
                    self.addShareActivityLog()
                }
            }
          //  Core.share(with: navCont, image: shareImg, content: text)
        }
       
//        Core.sharePicture(with: self)
//        Core.shareContent(self, displayName: profileData?.Fname ?? "Guest") { status in
//            
//        }
    }
    
    // MARK: Add into activity log
    private func addShareActivityLog() {
        if !Reachability.isConnectedToNetwork() {
            return
        }
        DispatchQueue.global(qos: .background).async {
            ActivityClient.shareActivityLog { status in
                //print("shareActivityLog: \(status ?? false)")
            }
        }
    }
    
    // MARK: - Logging -
    
    @objc func clickOnClose(_ sender: UIButton) {
        sideMenuController?.hideRightView(animated: true)
    }

    deinit {
        struct Counter { static var count = 0 }
        Counter.count += 1
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set notification center for audio playing completed
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserData(_:)), name: Notification.Name(rawValue: "updateUserData"), object: nil)
        struct Counter { static var count = 0 }
        Counter.count += 1
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        struct Counter { static var count = 0 }
        Counter.count += 1
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        struct Counter { static var count = 0 }
        Counter.count += 1
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "updateUserData"), object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        struct Counter { static var count = 0 }
        Counter.count += 1
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        struct Counter { static var count = 0 }
        Counter.count += 1
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.view.clipsToBounds = true
    }
}

// MARK: - UITableViewDelegate -
extension RightViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sideMenuController = sideMenuController else { return }
        let item = sections[indexPath.section][indexPath.row]

        func getNavigationController() -> UINavigationController {
            return sideMenuController.rootViewController as! UINavigationController
        }
        sideMenuController.hideRightView(animated: false)
        if UserDefaults.standard.bool(forKey: Constants.UserDefault.IsLogin) {
            switch item {
            case .logout:
                if let lastView = self.sideMenuController?.rootViewController?.children.last {
                    PromptVManager.present(lastView, isLogoutView: true)
                }
                return
            default:
                self.pushToView(item.storyboardId, controllerName: item.controllerName)
//                let domain = Bundle.main.bundleIdentifier!
//                UserDefaults.standard.removePersistentDomain(forName: domain)
//                UserDefaults.standard.synchronize()
//                AudioPlayManager.shared.isMiniPlayerActive = false
//                AudioPlayManager.shared.isNonStop = false
//
//                Login.setGusetData()
//                if let cont = sideMenuController.rootViewController as? UINavigationController {
//                    var contStacks = [UIViewController]()
//                    if let myobject = UIStoryboard(name: Constants.Storyboard.launch, bundle: nil).instantiateViewController(withIdentifier: "LaunchViewController") as? LaunchViewController {
//                        contStacks.append(myobject)
//                    }
//                    if let myobject = UIStoryboard(name: Constants.Storyboard.dashboard, bundle: nil).instantiateViewController(withIdentifier: "DashboardViewController") as? DashboardViewController {
//                        contStacks.append(myobject)
//                    }
//                    cont.viewControllers = contStacks
//                    let myobject = UIStoryboard(name: Constants.Storyboard.auth, bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
//                    cont.pushViewController(myobject, animated: true)
//                }
                return
            }
        } else {
            self.pushToView(Constants.Storyboard.auth, controllerName: "LoginViewController")
        }
    }
    
    private func pushToView(_ storyBoardId: String, controllerName: String) {
        if storyBoardId.isBlank {
            return
        }
        guard let sideMenuController = sideMenuController else { return }
        if let cont = sideMenuController.rootViewController as? UINavigationController, let navLastChild = cont.children.last {
            if controllerName == LaunchViewController().className {
                let myobject = UIStoryboard(name: storyBoardId, bundle: nil).instantiateViewController(withIdentifier: controllerName)
                if let trivia = myobject as? LaunchViewController {
                    trivia.showTutorial = true
                }
                cont.pushViewController(myobject, animated: true)
                return
            }
            if navLastChild.className != controllerName  {
                for controller in cont.children {
                    if controller.className == controllerName {
                        cont.popToViewController(controller, animated: true)
                        if storyBoardId == Constants.Storyboard.dashboard && controllerName == DashboardViewController().className {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ChangeSegmentNow"), object: nil, userInfo: nil)
                        }
                        return
                    }
                }
                let myobject = UIStoryboard(name: storyBoardId, bundle: nil).instantiateViewController(withIdentifier: controllerName)
                if let trivia = myobject as? TriviaViewController {
                    trivia.fromSideMenu = true
                }
                cont.pushViewController(myobject, animated: true)
                if storyBoardId == Constants.Storyboard.dashboard && controllerName == DashboardViewController().className {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ChangeSegmentNow"), object: nil, userInfo: nil)
                }
            } else if storyBoardId == Constants.Storyboard.dashboard && controllerName == DashboardViewController().className {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ChangeSegmentNow"), object: nil, userInfo: nil)
            }
            
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return cellProfileHeight
        }
        return cellHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        }
        return cellHeight / 2.0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
}

// MARK: - UITableViewDataSource -
extension RightViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UserDefaults.standard.bool(forKey: Constants.UserDefault.IsLogin) {
            return sections[section].count
        }
        return sections[section].count - 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            //profileCell
            let cell = tableView.dequeueReusableCell(withIdentifier: cellProfileIdentifier, for: indexPath) as! RightViewCell
            
            cell.titleLabel.text = profileData?.Fname ?? "Guest"
            cell.subTitleLabel.text = "+\(profileData?.Isd_code ?? 0) \(profileData?.Phone ?? "00000 00000")"
            if let imgData = profileData?.ImageData, let img = UIImage(data: imgData) {
                cell.profileImage.image = img
            } else {
                cell.profileImage.image = Login.defaultProfileImage
            }
            cell.closeButton.addTarget(self, action: #selector(self.clickOnClose(_:)), for: .touchUpInside)
            cell.isFirst = (indexPath.row == 0)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RightViewCell
        var item = sections[indexPath.section][indexPath.row]
        if item == .logout && !UserDefaults.standard.bool(forKey: Constants.UserDefault.IsLogin) {
            item = sections[indexPath.section].last!
        }
        cell.titleLabel.text = item == .appVersion ? (Constants.baseURL == "https://live.taleometer.com" ? "Live" : "UAT") + " V\(Core.GetAppVersion())" : item.description
        cell.isFirst = (indexPath.row == 0)
        cell.isLast = (indexPath.row == sections[indexPath.section].count - 1)
        cell.selectionStyle = .none
        return cell
    }
}
