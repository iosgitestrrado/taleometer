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
        case shareStory
        case history
        case preference
        case aboutUs
        case feedback

        var description: String {
            switch self {
            case .profile:
                return "My Account"
            case .shareStory:
                return "Share your Story"
            case .history:
                return "History"
            case .preference:
                return "Preference"
            case .aboutUs:
                return "About us"
            case .feedback:
                return "Feedback"
            }
        }
    }
    
    private let sections: [[SideViewCellItem]] = [
        [.profile, .profile, .shareStory, .history, .preference, .aboutUs, .feedback]
    ]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserData(_:)), name: Notification.Name(rawValue: "updateUserData"), object: nil)
    }
    
    @objc private func updateUserData(_ notification: Notification) {
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
        sideMenuController.hideRightView(animated: true)
        if UserDefaults.standard.bool(forKey: "isLogin") {
            switch item {
            case .profile:
                if let cont = sideMenuController.rootViewController as? UINavigationController {
                    let myobject = UIStoryboard(name: Storyboard.auth, bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController")
                    cont.pushViewController(myobject, animated: true)
                }
                return
            case .shareStory:
                if let cont = sideMenuController.rootViewController as? UINavigationController, let lastView = cont.children.last, (lastView as? MainUserStoryVC) == nil {
                    let myobject = UIStoryboard(name: Storyboard.other, bundle: nil).instantiateViewController(withIdentifier: "MainUserStoryVC")
                    cont.pushViewController(myobject, animated: true)
                }
                return
            case .preference:
                if let cont = sideMenuController.rootViewController as? UINavigationController, let lastView = cont.children.last, (lastView as? SettingViewController) == nil {
                    let myobject = UIStoryboard(name: Storyboard.other, bundle: nil).instantiateViewController(withIdentifier: "SettingViewController")
                    cont.pushViewController(myobject, animated: true)
                }
                return
            case .history:
                if let cont = sideMenuController.rootViewController as? UINavigationController, let lastView = cont.children.last, (lastView as? HistoryViewController) == nil {
                    let myobject = UIStoryboard(name: Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "HistoryViewController")
                    cont.pushViewController(myobject, animated: true)
                }
                return
            case .feedback:
                if let cont = sideMenuController.rootViewController as? UINavigationController, let lastView = cont.children.last, (lastView as? FeedbackViewController) == nil {
                    let myobject = UIStoryboard(name: Storyboard.other, bundle: nil).instantiateViewController(withIdentifier: "FeedbackViewController")
                    cont.pushViewController(myobject, animated: true)
                }
                return
            case .aboutUs:
                if let cont = sideMenuController.rootViewController as? UINavigationController, let lastView = cont.children.last, (lastView as? AboutUsViewController) == nil {
                    let myobject = UIStoryboard(name: Storyboard.other, bundle: nil).instantiateViewController(withIdentifier: "AboutUsViewController")
                    cont.pushViewController(myobject, animated: true)
                }
                return
            }
        } else {
            if let cont = sideMenuController.rootViewController as? UINavigationController {
                let myobject = UIStoryboard(name: Storyboard.auth, bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
                cont.pushViewController(myobject, animated: true)
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
        return sections[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            //profileCell
            let cell = tableView.dequeueReusableCell(withIdentifier: cellProfileIdentifier, for: indexPath) as! RightViewCell
            
            cell.titleLabel.text = UserDefaults.standard.string(forKey: "ProfileName") ?? "Guest"
            cell.subTitleLabel.text = UserDefaults.standard.string(forKey: "ProfileMobile") ?? "+0 00000 00000"
            if let imgData = UserDefaults.standard.object(forKey: "ProfileImage") as? Data, let img = UIImage(data: imgData) {
                cell.profileImage.image = img
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
