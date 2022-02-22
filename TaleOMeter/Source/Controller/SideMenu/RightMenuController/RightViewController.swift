//
//  RightViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 12/02/22.
//

import UIKit

private let cellProfileIdentifier = "profileCell"
private let cellIdentifier = "cell"
private let tableViewInset: CGFloat = 44.0 * 2.0
private let cellHeight: CGFloat = 44.0
private let cellProfileHeight: CGFloat = 153.0

class RightViewController: UIViewController {
    
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
        
        switch item {
            case .profile:
            if let cont = sideMenuController.rootViewController as? UINavigationController {
                let myobject = UIStoryboard(name: Storyboard.auth, bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController")
                cont.pushViewController(myobject, animated: true)
            }
                return
            default:
                Core.present(self, storyboard: Storyboard.audio, storyboardId: "CommingViewController")
                return
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
            cell.titleLabel.text = "Durgesh Timbadiya"
            cell.subTitleLabel.text = "+91 98989 98989"
            cell.closeButton.addTarget(self, action: #selector(self.clickOnClose(_:)), for: .touchUpInside)
            cell.isFirst = (indexPath.row == 0)

            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RightViewCell
        let item = sections[indexPath.section][indexPath.row]

        cell.titleLabel.text = item.description
        cell.isFirst = (indexPath.row == 0)
        cell.isLast = (indexPath.row == sections[indexPath.section].count - 1)
        return cell
    }
}
