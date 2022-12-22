//
//  SearchHistoryViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit

class SearchHistoryViewController: UIViewController {

    // MARK: - Weak Property -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerBottomCons: NSLayoutConstraint!
    
    // MARK: - Private Property -
    private var recentSearchArray = [String]()
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboard()
//        self.tableView.tableHeaderView = self.searchBar        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: false)
        self.navigationItem.title = "Search History"
        //Add footer view and manager current view frame
        FooterManager.addFooter(self, bottomConstraint: self.containerBottomCons)
        if AudioPlayManager.shared.isMiniPlayerActive {
            AudioPlayManager.shared.addMiniPlayer(self, bottomConstraint: self.containerBottomCons)
        }
        
        if let recentData = userDefaults.object(forKey: "recentSearch") as? [String] {
            recentSearchArray = recentData
        }
    }
    
    @objc private func tapOnRemove(_ sender: UIButton) {
        self.recentSearchArray.remove(at: sender.tag)
        self.tableView.reloadData()
        storeRecentSearch()
    }
    
    private func storeRecentSearch() {
        userDefaults.set(recentSearchArray, forKey: "recentSearch")
    }
}

// MARK: - UITableViewDataSource -
extension SearchHistoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearchArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "audioCell", for: indexPath) as? AudioViewCell else { return UITableViewCell() }
        if let image = cell.profileImage {
            image.cornerRadius = image.frame.size.height / 2.0
        }
        if let titleLbl = cell.titleLabel {
            titleLbl.text = recentSearchArray[indexPath.row]
        }
        if let removeButon = cell.playButton {
            removeButon.tag = indexPath.row
            removeButon.addTarget(self, action: #selector(tapOnRemove(_:)), for: .touchUpInside)
        }
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITableViewDelegate -
extension SearchHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if recentSearchArray.count <= 0 {
            return 30
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if recentSearchArray.count <= 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell") as? AudioViewCell else { return UIView() }
            return cell
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Core.push(self, storyboard: Constants.Storyboard.audio, storyboardId: "AuthorViewController")
    }
}

// MARK: - PromptViewDelegate -
extension SearchHistoryViewController: PromptViewDelegate {
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
        AudioPlayManager.shared.didActionOnPromptButton(tag)
    }
}
