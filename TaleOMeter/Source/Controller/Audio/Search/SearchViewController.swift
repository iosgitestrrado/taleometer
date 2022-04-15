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
    private var searchArray = [Audio]()
    private var allListArray = ["Trackts To Relax", "Asked The Mentor", "A Lotta Laungh", "Learn Brightly", "Creative Events", "Design Life", "Writer's Panel", "Last Cure", "Togather Share", "Trackts To Relax", "Asked The Mentor", "A Lotta Laungh", "Learn Brightly", "Creative Events", "Design Life", "Writer's Panel", "Last Cure", "Togather Share"]
    private var recentSearchArray = [SearchAudio]()
    private var isRecentSearch = true
    private let userDefaults = UserDefaults.standard
    private var originalConBotCons = 0.0
    private let throttler = Throttler(minimumDelay: 0.5)
    
    private var footerView = UIView()
    private var morePage = [true, true] // first for search and second for recent search
    private var pageNumber = [1, 1]
    private var limit = [10, 10]
    private var showNoData = [0, 10]
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboard()
//        self.tableView.tableHeaderView = self.searchBar
        Core.initFooterView(self, footerView: &footerView)
        self.searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.leftView?.tintColor = .black
        searchBar.searchTextField.textColor = .black
        self.tableView.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "NoDataTableViewCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
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
//        if let recentData = userDefaults.object(forKey: "recentSearch") as? [String] {
//            recentSearchArray = recentData
//        }
//        self.tableView.reloadData()
        self.getRecent()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func tapOnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func tapOnRemove(_ sender: UIButton) {
        self.removeRecent(self.recentSearchArray[sender.tag].Id)
    }
    
    @objc private func tapOnRemoveAll(_ sender: UIButton) {
        self.removeRecent(0, removeAll: true)
       // Core.push(self, storyboard: Constants.Storyboard.audio, storyboardId: "SearchHistoryViewController")
    }
    
    @objc private func keyboardWillShowNotification (notification: Notification) {
        if self.containerBottomCons.constant == originalConBotCons, let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height - self.view.safeAreaInsets.bottom
            self.containerBottomCons.constant = keyboardHeight
        }
    }
    
    @objc private func keyboardWillHideNotification (notification: Notification) {
        if self.containerBottomCons.constant != originalConBotCons {
            self.containerBottomCons.constant = originalConBotCons
        }
    }
}

// MARK: - Get data from server
extension SearchViewController {
    private func get(_ searchText: String, isLoading: Bool = true) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        if isLoading {
            Core.ShowProgress(self, detailLbl: "")
        }
        SearchAudioClient.get(SearchAudioRequest(text: searchText, page: "\(pageNumber[0])", limit: limit[0])) { [self] response in
            if let data = response {
                searchArray = searchArray + data
                morePage[0] = data.count > 0
            }
            showNoData[0] = 1
            tableView.reloadData()
            tableView.tableFooterView = UIView()
            if isLoading {
                Core.HideProgress(self)
            }
        }
    }
    
    private func getRecent(_ isLoading: Bool = true) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        if isLoading {
            Core.ShowProgress(self, detailLbl: "")
        }
        SearchAudioClient.getRecent("\(pageNumber[1])", limit: limit[1]) { [self] response in
            if let data = response {
                recentSearchArray = recentSearchArray + data
                var res: [SearchAudio] = [SearchAudio]()
                recentSearchArray.forEach { (p) -> () in
                    if !res.contains(where: { $0.Id == p.Id }) {
                        res.append(p)
                    }
                }
                recentSearchArray = res
                morePage[1] = data.count > 0
            }
            showNoData[1] = 1
            tableView.reloadData()
            tableView.tableFooterView = UIView()
            if isLoading {
                Core.HideProgress(self)
            }
        }
    }
    
    private func removeRecent(_ search_id: Int, removeAll: Bool = false) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        SearchAudioClient.delete(SearchDeleteRequest(audio_search_id: search_id), removeAll: removeAll) { [self] status in
            if let st = status, st {
                if removeAll {
                    recentSearchArray = [SearchAudio]()
                    morePage[1] = true
                    showNoData[1] = 0
                    pageNumber[1] = 1
                } else if let sIndex = recentSearchArray.firstIndex(where: { $0.Id == search_id }) {
                    recentSearchArray.remove(at: sIndex)
                }
                getRecent(false)
            }
            Core.HideProgress(self)
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
            return recentSearchArray.count > 0 ? self.recentSearchArray.count : showNoData[1]
        }
        return searchArray.count > 0 ? self.searchArray.count : showNoData[0]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.isRecentSearch && self.recentSearchArray.count <= 0) || (!self.isRecentSearch && self.searchArray.count <= 0) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataTableViewCell", for: indexPath) as? NoDataTableViewCell else { return UITableViewCell() }
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "audioCell", for: indexPath) as? AudioViewCell else { return UITableViewCell() }
        if let image = cell.profileImage {
            if !self.isRecentSearch {
                image.cornerRadius = image.frame.size.height / 2.0
                image.sd_setImage(with: URL(string: searchArray[indexPath.row].ImageUrl), placeholderImage: defaultImage, options: [], context: nil)
            }
            image.isHidden = self.isRecentSearch
        }
        if let titleLbl = cell.titleLabel {
            titleLbl.text = self.isRecentSearch ? recentSearchArray[indexPath.row].Text : searchArray[indexPath.row].Title
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
        if isRecentSearch {
            return self.recentSearchArray.count <= 0 ? (showNoData[1] == 1 ? 30 : 0) : 60
        }
        return self.searchArray.count <= 0 ? (showNoData[0] == 1 ? 30 : 0) : 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.isRecentSearch && recentSearchArray.count > 0 {
            return 30
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if (self.isRecentSearch && recentSearchArray.count <= 0) || (!self.isRecentSearch && searchArray.count <= 0) {
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell") as? AudioViewCell else { return UIView() }
//            return cell
//        }
        if !self.isRecentSearch {
            return UIView()
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "recentCell") as? AudioViewCell else { return UIView() }
        if let removeButon = cell.playButton {
            removeButon.addTarget(self, action: #selector(tapOnRemoveAll(_:)), for: .touchUpInside)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isRecentSearch {
            self.searchBar.becomeFirstResponder()
            self.searchBar.text = recentSearchArray[indexPath.row].Text
            self.isRecentSearch = false
            if (searchBar.text?.utf8.count)! > 0 {
                throttler.throttle {
                    DispatchQueue.main.async { [self] in
                        searchArray = [Audio]()
                        morePage[0] = true
                        pageNumber[0] = 1
                        showNoData[0] = 0
                        get(searchBar.text!)
                    }
                }
            }
            return
        }
        if let myobject = UIStoryboard(name: Constants.Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "NowPlayViewController") as? NowPlayViewController {
//            if let audioUrl = URL(string: searchArray[indexPath.row].File) {
//                let fileName = NSString(string: audioUrl.lastPathComponent)
//                if !supportedAudioExtenstion.contains(fileName.pathExtension.lowercased()) {
//                    Toast.show("Audio File \"\(fileName.pathExtension)\" is not supported!")
//                    return
//                }
//            }
            if AudioPlayManager.shared.isNonStop {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "closeMiniPlayer"), object: nil)
            }
            AudioPlayManager.shared.audioList = searchArray
            AudioPlayManager.shared.setAudioIndex(indexPath.row ,isNext: false)
            self.navigationController?.pushViewController(myobject, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isRecentSearch {
            if recentSearchArray.count > 9 && indexPath.row == recentSearchArray.count - 1 && self.morePage[1] {
                //last cell load more
                pageNumber[1] += 1
                tableView.tableFooterView = footerView
                if let indicator = footerView.viewWithTag(10) as? UIActivityIndicatorView {
                    indicator.startAnimating()
                }
                DispatchQueue.global(qos: .background).async { DispatchQueue.main.async { self.getRecent(false) } }
            }
        } else {
            if searchArray.count > 9 && indexPath.row == searchArray.count - 1 && self.morePage[0] {
                //last cell load more
                pageNumber[0] += 1
                tableView.tableFooterView = footerView
                if let indicator = footerView.viewWithTag(10) as? UIActivityIndicatorView {
                    indicator.startAnimating()
                }
                DispatchQueue.global(qos: .background).async { DispatchQueue.main.async { self.get(self.searchBar.text!, isLoading: false) } }
            }
        }
    }
}

// MARK: - UISearchBarDelegate -
extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text?.utf8.count)! > 0 {
            throttler.throttle {
                DispatchQueue.main.async {
                    self.searchArray = [Audio]()
                    self.morePage[0] = true
                    self.pageNumber[0] = 1
                    self.showNoData[0] = 0
                    self.get(searchBar.text!)
                }
            }
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.isRecentSearch = false
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.isRecentSearch = true
        self.searchBar.text = ""
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
