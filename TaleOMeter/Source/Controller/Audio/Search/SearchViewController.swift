//
//  SearchViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit

class SearchViewController: UIViewController {

    // MARK: - Weak Property -
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerBottomCons: NSLayoutConstraint!
    
    // MARK: - Private Property -
    private var listArray = [String]()
    private var allListArray = ["Trackts To Relax", "Asked The Mentor", "A Lotta Laungh", "Learn Brightly", "Creative Events", "Design Life", "Writer's Panel", "Last Cure", "Togather Share", "Trackts To Relax", "Asked The Mentor", "A Lotta Laungh", "Learn Brightly", "Creative Events", "Design Life", "Writer's Panel", "Last Cure", "Togather Share"]
    private var filteredListArray = [String]()
    private var recentSearchArray = [String]()
    private var isRecentSearch = true
    private let userDefaults = UserDefaults.standard
    private var originalConBotCons = 0.0
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboard()
//        self.tableView.tableHeaderView = self.searchBar
        self.searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.leftView?.tintColor = .black
        searchBar.searchTextField.textColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: true, isRightViewEnabled: false)
        
        //Add footer view and manager current view frame
        FooterManager.addFooter(self, bottomConstraint: self.containerBottomCons, isSearch: true)
        if AudioPlayManager.shared.isMiniPlayerActive {
            AudioPlayManager.shared.addMiniPlayer(self, bottomConstraint: self.containerBottomCons)
        }
        originalConBotCons = self.containerBottomCons.constant
        if let recentData = userDefaults.object(forKey: "recentSearch") as? [String] {
            recentSearchArray = recentData
        }
        self.tableView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func tapOnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func tapOnRemove(_ sender: UIButton) {
        if isRecentSearch {
            self.recentSearchArray.remove(at: sender.tag)
            self.tableView.reloadData()
            storeRecentSearch()
        }
    }
    
    @objc private func tapOnViewAll(_ sender: UIButton) {
        Core.push(self, storyboard: Constants.Storyboard.audio, storyboardId: "SearchHistoryViewController")
    }
    
    private func storeRecentSearch() {
        userDefaults.set(recentSearchArray, forKey: "recentSearch")
    }
    
    @objc private func keyboardWillShowNotification (notification: Notification) {
        if self.containerBottomCons.constant == originalConBotCons,let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.containerBottomCons.constant = keyboardHeight
        }
    }
    
    @objc private func keyboardWillHideNotification (notification: Notification) {
        if self.containerBottomCons.constant != originalConBotCons {
            self.containerBottomCons.constant = originalConBotCons
        }
    }
}

// MARK: - UITableViewDataSource -
extension SearchViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isRecentSearch {
            return recentSearchArray.count
        }
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "audioCell", for: indexPath) as? AudioViewCell else { return UITableViewCell() }
        if let image = cell.profileImage {
            image.cornerRadius = image.frame.size.height / 2.0
        }
        if let titleLbl = cell.titleLabel {
            if (self.isRecentSearch) {
                titleLbl.text = recentSearchArray[indexPath.row]
            } else {
                titleLbl.text = listArray[indexPath.row]
            }
        }
        if let removeButon = cell.playButton {
            removeButon.isHidden = !self.isRecentSearch
            if (self.isRecentSearch) {
                removeButon.tag = indexPath.row
                removeButon.addTarget(self, action: #selector(tapOnRemove(_:)), for: .touchUpInside)
            }
        }
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITableViewDelegate -
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (self.isRecentSearch && recentSearchArray.count <= 0) || (!self.isRecentSearch && listArray.count <= 0) {
            return 30
        }
        if !self.isRecentSearch {
            return 0
        }
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (self.isRecentSearch && recentSearchArray.count <= 0) || (!self.isRecentSearch && listArray.count <= 0) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell") as? AudioViewCell else { return UIView() }
            return cell
        }
        if !self.isRecentSearch {
            return UIView()
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "recentCell") as? AudioViewCell else { return UIView() }
        if let removeButon = cell.playButton {
            removeButon.addTarget(self, action: #selector(tapOnViewAll(_:)), for: .touchUpInside)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isRecentSearch {
            if recentSearchArray.contains(listArray[indexPath.row]), let idx = recentSearchArray.firstIndex(of: listArray[indexPath.row]) {
                recentSearchArray.remove(at: idx)
            }
            recentSearchArray.append(listArray[indexPath.row])
            storeRecentSearch()
        }
        Core.push(self, storyboard: Constants.Storyboard.audio, storyboardId: "AuthorViewController")
    }
}

// MARK: - UISearchBarDelegate -
extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.isRecentSearch = false
        listArray.removeAll(keepingCapacity: false)
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchBar.text!)
        let array = (allListArray as NSArray).filtered(using: searchPredicate)
        listArray = array as! [String]
        self.tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.isRecentSearch = true
        self.tableView.reloadData()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        self.view.endEditing(true)
        if (searchBar.text?.utf8.count)! <= 0 {
            self.isRecentSearch = true
            self.tableView.reloadData()
        }
    }
}

// MARK: - PromptViewDelegate -
extension SearchViewController: PromptViewDelegate {
    func didActionOnPromptButton(_ tag: Int) {
        AudioPlayManager.shared.didActionOnPromptButton(tag)
    }
}
