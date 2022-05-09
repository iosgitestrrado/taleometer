//
//  RightViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 12/02/22.
//

import UIKit

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
//        case triviaComments
        case shareStory
        case history
        case preference
        case aboutUs
        case feedback
        case logout

        var description: String {
            switch self {
            case .profile:
                return "My Account"
            case .triviaQuiz:
                return "Trivia"
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
            case .feedback:
                return "Contact Us"
            case .logout:
                return "Logout"
            }
        }
        
        var storyboardId: String {
            switch self {
            case .profile:
                return Constants.Storyboard.auth
            case .triviaQuiz/*, .triviaComments*/:
                return Constants.Storyboard.trivia
            case .shareStory, .preference, .aboutUs, .feedback:
                return Constants.Storyboard.other
            case .history:
                return Constants.Storyboard.audio
            case .logout:
                return Constants.Storyboard.auth
            }
        }
        
        var storyboardName: String {
            switch self {
            case .profile:
                return "ProfileViewController"
            case .triviaQuiz:
                return "TriviaViewController"
//            case .triviaComments:
//                return "TRFeedViewController"
            case .shareStory:
                return "MainUserStoryVC"
            case .history:
                return "HistoryViewController"
            case .preference:
                return "SettingViewController"
            case .aboutUs:
                return "AboutUsViewController"
            case .feedback:
                return "FeedbackViewController"
            case .logout:
                return "LoginViewController"
            }
        }
    }
    
    private var sections: [[SideViewCellItem]] = [
        [.profile, .triviaQuiz/*, .triviaComments*/, .shareStory, .history, .preference, .aboutUs, .feedback, .logout]
    ]
    
    private let triviaSections: [[SideViewCellItem]] = [
        [.profile, .profile, .preference, .aboutUs, .feedback, .logout]
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
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
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
                if !Reachability.isConnectedToNetwork() {
                    Core.noInternet(self)
                    return
                }
                AuthClient.logout("", moveToLogin: false)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                self.pushToView(item.storyboardId, storyBoradId: item.storyboardName)
                return
            default:
                self.pushToView(item.storyboardId, storyBoradId: item.storyboardName)
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
            self.pushToView(Constants.Storyboard.auth, storyBoradId: "LoginViewController")
        }
    }
    
    private func pushToView(_ storyBoardName: String, storyBoradId: String) {
        guard let sideMenuController = sideMenuController else { return }
        if let cont = sideMenuController.rootViewController as? UINavigationController, let navLastChild = cont.children.last, navLastChild.className != storyBoradId {
            for controller in cont.children {
                if controller.className == storyBoradId {
                    cont.popToViewController(controller, animated: true)
                    return
                }
            }
            let myobject = UIStoryboard(name: storyBoardName, bundle: nil).instantiateViewController(withIdentifier: storyBoradId)
            if let trivia = myobject as? TriviaViewController {
                trivia.fromSideMenu = true
            }
            cont.pushViewController(myobject, animated: true)
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
        let item = sections[indexPath.section][indexPath.row]

        cell.titleLabel.text = item.description
        cell.isFirst = (indexPath.row == 0)
        cell.isLast = (indexPath.row == sections[indexPath.section].count - 1)
        cell.selectionStyle = .none
        return cell
    }
}
