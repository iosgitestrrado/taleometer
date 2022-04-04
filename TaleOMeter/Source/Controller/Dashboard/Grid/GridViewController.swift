//
//  GridViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit
import UIScrollView_InfiniteScroll

class GridViewController: UIViewController {

    // MARK: - Public Properties -
    @IBOutlet weak var tableView: UITableView!
    var parentController: UIViewController?
    var parentFrame: CGRect?
    var genreId = -1
    var totalGenres = 0
    
    // MARK: - Private Properties -
    private var audioList = [Audio]()
    private var currentIndex = -1
    private var totalRowCount = 0
    
    private var footerView = UIView()
    private var morePage = true
    private var pageNumber = 1
    private var pageLimit = 9
    private var showNoData = 0

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Set collection view frame
        //self.tableView.frame.size.width = parentFrame!.size.width
        if genreId < 0 {
            currentIndex = 0
            self.tableView.reloadData()
            return
        }
        
        // Enable vertical scroll always
        self.tableView.alwaysBounceVertical = true
        
        // Set table view basic tableview property
        morePage = UserDefaults.standard.bool(forKey: Constants.UserDefault.IsLogin)
        self.tableView.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "NoDataTableViewCell")
        Core.initFooterView(self, footerView: &footerView)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Add infinite scroll handler
    }
    
    func loadAudioList() {
        if audioList.count <= 0 {
            audioList = [Audio]()
            self.getAudios()
        }
    }
    
    func getAudios(_ showProgress: Bool = true) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(parentController!)
            //completionHandler?()
            return
        }
        if showProgress {
            Core.ShowProgress(parentController!, detailLbl: "")
        }
        AudioClient.get(AudioRequest(page: "\(pageNumber)", limit: pageLimit), genreId: genreId, completion: { [self] response in
            if let data = response {
                morePage = data.count > 0
                audioList = audioList + data
                totalRowCount = audioList.count % 3 == 0 ? audioList.count / 3 : (audioList.count / 3) + 1
            }
            showNoData = 1
            tableView.reloadData()
            tableView.tableFooterView = UIView()
            if showProgress {
                Core.HideProgress(parentController!)
            }
        })
    }
    
    // MARK: - Actions
    @IBAction func handleRefresh() {
        //collectionView?.beginInfiniteScroll(true)
    }
}

// MARK: - UITableViewDataSource -
extension GridViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.audioList.count > 0 ? totalRowCount : showNoData
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.audioList.count <= 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataTableViewCell", for: indexPath) as? NoDataTableViewCell else { return UITableViewCell() }
            return cell
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "gridCell", for: indexPath) as? GridViewTableCell {
            let row = indexPath.row * 3
            
            if row <= audioList.count - 1 {
                if let img = cell.imageView1, let imgBack = cell.imgBackView2, let lbl = cell.titleLabe1, let btn = cell.rowButton1, let cntLbl = cell.numberOfCountLbl1 {
                    self.setGrid(img, imageBack: imgBack, label: lbl, button: btn, countLbl: cntLbl, indexRow: row)
                }
            }
            if let img = cell.imageView2, let imgBack = cell.imgBackView2, let lbl = cell.titleLabe2, let btn = cell.rowButton2, let cntLbl = cell.numberOfCountLbl2 {
                imgBack.isHidden = true
                lbl.isHidden = true
                btn.isHidden = true
                if row + 1 <= audioList.count - 1 {
                    self.setGrid(img, imageBack: imgBack, label: lbl, button: btn, countLbl: cntLbl, indexRow: row + 1)
                }
            }
            if let img = cell.imageView3, let imgBack = cell.imgBackView3, let lbl = cell.titleLabe3, let btn = cell.rowButton3, let cntLbl = cell.numberOfCountLbl3 {
                imgBack.isHidden = true
                lbl.isHidden = true
                btn.isHidden = true
                if row + 2 <= audioList.count - 1 {
                    self.setGrid(img, imageBack: imgBack, label: lbl, button: btn, countLbl: cntLbl, indexRow: row + 2)
                }
            }
            return cell
        }
        
        return UITableViewCell()
    }
    
    // MARK: - Set image label and button index for grid
    private func setGrid(_ image: UIImageView, imageBack: UIView, label: UILabel, button: UIButton, countLbl: UILabel, indexRow: Int) {
        image.sd_setImage(with: URL(string: audioList[indexRow].ImageUrl), placeholderImage: defaultImage, options: [], context: nil)
        imageBack.isHidden = false
        image.isHidden = false

        label.text = audioList[indexRow].Title
        label.isHidden = false
        
        button.tag = indexRow
        button.addTarget(self, action: #selector(tapOnGrid(_:)), for: .touchUpInside)
        button.isHidden = false
        countLbl.text = audioList[indexRow].Views_count.formatPoints()
    }
}

// MARK: - UITableViewDelegate -
extension GridViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.audioList.count <= 0 && showNoData == 1 ? 30.0 : 130.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if UserDefaults.standard.bool(forKey: Constants.UserDefault.IsLogin), totalRowCount >= 2 && indexPath.row == totalRowCount - 1 && self.morePage {
            //last cell load more
            pageNumber += 1
            tableView.tableFooterView = footerView
            if let indicator = footerView.viewWithTag(10) as? UIActivityIndicatorView {
                indicator.startAnimating()
            }
            DispatchQueue.global(qos: .background).async { DispatchQueue.main.async { self.getAudios(false) } }
        }
    }
    
    // MARK: - Tap on grid index
    @objc private func tapOnGrid(_ sender: UIButton) {
        if UserDefaults.standard.bool(forKey: Constants.UserDefault.IsLogin) {
            if let myobject = UIStoryboard(name: Constants.Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "NowPlayViewController") as? NowPlayViewController {
                if AudioPlayManager.shared.isNonStop {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "closeMiniPlayer"), object: nil)
                }
                myobject.myAudioList = audioList
                myobject.currentAudioIndex = sender.tag
                AudioPlayManager.shared.audioList = audioList
                AudioPlayManager.shared.setAudioIndex(sender.tag, isNext: false)
                parentController!.navigationController?.pushViewController(myobject, animated: true)
            }
        } else {
            Core.push(self.parentController!, storyboard: Constants.Storyboard.auth, storyboardId: "LoginViewController")
        }
    }
}

// MARK: - UIScrollViewDelegate -
extension GridViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let cont = self.parentController as? DashboardViewController, cont.surpriseButton.isHidden, scrollView.contentOffset.y < -20.0 {
            UIView.transition(with: cont.surpriseButton, duration: 1.0, options: .transitionCrossDissolve) {
                cont.surpriseButton.isHidden = false
            }
        } else if let cont = self.parentController as? GuestDashboardViewController, cont.surpriseButton.isHidden, scrollView.contentOffset.y < -20.0 {
            UIView.transition(with: cont.surpriseButton, duration: 1.0, options: .transitionCrossDissolve) {
                cont.surpriseButton.isHidden = false
            }
        }
    }
}

