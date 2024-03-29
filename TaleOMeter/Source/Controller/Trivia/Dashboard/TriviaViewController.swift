//
//  TriviaViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 03/03/22.
//

import UIKit

class TriviaViewController: UIViewController {
    
    //1E1E30
    // MARK: - Weak Properties -
    @IBOutlet weak var collectionView: UICollectionView!
    
    var fromSideMenu = false
    @IBOutlet weak var containerBottomCons: NSLayoutConstraint!
    
    // MARK: - Private Properties -
    private var gridWidth: CGFloat = 187.0
    private var gridHeight: CGFloat = 225.0
    private var titleViewHeight: CGFloat = 50.0
//    private struct ItemModel {
//        var title = String()
//        var count = Int()
//        var image = String()
//    }
//    private var tilesArray: [ItemModel] = {
//        var tilesArraytem = [ItemModel]()
//        tilesArraytem.append(ItemModel(title: "Daily", count: 20, image: "Book-Covers"))
//        tilesArraytem.append(ItemModel(title: "Food Stories", count: 20, image: "food"))
//        tilesArraytem.append(ItemModel(title: "Epic Tales", count: 20, image: "Book-Covers"))
//        tilesArraytem.append(ItemModel(title: "Music Stories", count: 20, image: "Album"))
//        tilesArraytem.append(ItemModel(title: "Food Stories", count: 20, image: "food"))
//        return tilesArraytem
//    }()
    
    private var triviaHome = TriviaHome()

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        gridWidth = self.collectionView.frame.size.width / 2.0
        gridHeight = (gridWidth + titleViewHeight)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()//collectionView.collectionViewLayout as! UICollectionViewFlowLayout
       // layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: gridWidth, height: gridHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        collectionView.alwaysBounceVertical = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true, titleInLeft: false, backImage: true)
        self.navigationItem.hidesBackButton = !fromSideMenu
        if AudioPlayManager.shared.isMiniPlayerActive {
            AudioPlayManager.shared.addMiniPlayer(self, bottomConstraint: self.containerBottomCons)
        }
        if UserDefaults.standard.bool(forKey: Constants.UserDefault.IsLogin) {
            getTrivia()
            addActivityLog()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if fromSideMenu && isMovingFromParent {
            self.sideMenuController!.toggleRightView(animated: false)
        }
    }
    
    // MARK: Add into activity log
    private func addActivityLog() {
        if !Reachability.isConnectedToNetwork() {
            return
        }
        DispatchQueue.global(qos: .background).async {
            ActivityClient.userActivityLog(UserActivityRequest(post_id: "", category_id: "", screen_name: Constants.ActivityScreenName.triviaHome, type: Constants.ActivityType.trivia)) { status in
            }
        }
    }
    
    // MARK: - Get trivia home data from server -
    private func getTrivia() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        TriviaClient.getTriviaHome { response in
            if let data = response {
                self.triviaHome = data
            }
            self.collectionView.reloadData()
            Core.HideProgress(self)
        }
    }
    
    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        self.sideMenuController!.toggleRightView(animated: true)
    }
}

// MARK: - UICollectionViewDataSource -
extension TriviaViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(
                  ofKind: kind,
                  withReuseIdentifier: "headerCell",
                  for: indexPath)

            guard let headerView = headerView as? TriviaHeaderView
            else { return headerView }

            headerView.imageView.image = UIImage(named: "Default_img")
            headerView.titleLabel.text = "Tract To Relax"
            return headerView
        default:
            assert(false, "Invalid element type")
            return UICollectionReusableView()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return triviaHome.Trivia_category.count > 0 ? triviaHome.Trivia_category.count + 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? GridCollectionViewCell {
            if indexPath.row == 0 {
                cell.configureCell(triviaHome.Trivia_daily, gridWidth: gridWidth, gridHeight: gridHeight + 60.0, titleViewHeight: titleViewHeight, row: indexPath.row)
            } else {
                cell.configureCellCat(triviaHome.Trivia_category[indexPath.row - 1], gridWidth: gridWidth, gridHeight: gridHeight, titleViewHeight: titleViewHeight, row: indexPath.row)
            }
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegate -
extension TriviaViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 && triviaHome.Trivia_daily.Post_count_today == 0 {
            Toast.show(triviaHome.Trivia_daily.Post_msg)
            return
        }
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        if let myobject = UIStoryboard(name: Constants.Storyboard.trivia, bundle: nil).instantiateViewController(withIdentifier: "TRFeedViewController") as? TRFeedViewController {
            myobject.categoryId =  indexPath.row != 0 ? triviaHome.Trivia_category[indexPath.row - 1].Category_id : -1
            self.navigationController?.pushViewController(myobject, animated: true)
        }
       // Core.push(self, storyboard: Constants.Storyboard.trivia, storyboardId: "TRQuestionViewController")
    }
}

// MARK: - UICollectionViewDelegateFlowLayout -
extension TriviaViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            return CGSize(width: collectionView.frame.size.width, height: gridHeight + 60.0)
        }
        return CGSize(width: (collectionView.frame.size.width) / 2.0, height: gridHeight)
    }
}
