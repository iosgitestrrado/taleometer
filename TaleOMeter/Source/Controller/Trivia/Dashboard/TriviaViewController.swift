//
//  TriviaViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 03/03/22.
//

import UIKit

class TriviaViewController: UIViewController {
    
    // MARK: - Weak Properties -
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Private Properties -
    fileprivate var gridWidth: CGFloat = 187.0
    fileprivate var gridHeight: CGFloat = 225.0
    fileprivate var titleViewHeight: CGFloat = 50.0
//    fileprivate struct ItemModel {
//        var title = String()
//        var count = Int()
//        var image = String()
//    }
//    fileprivate var tilesArray: [ItemModel] = {
//        var tilesArraytem = [ItemModel]()
//        tilesArraytem.append(ItemModel(title: "Daily", count: 20, image: "Book-Covers"))
//        tilesArraytem.append(ItemModel(title: "Food Stories", count: 20, image: "food"))
//        tilesArraytem.append(ItemModel(title: "Epic Tales", count: 20, image: "Book-Covers"))
//        tilesArraytem.append(ItemModel(title: "Music Stories", count: 20, image: "Album"))
//        tilesArraytem.append(ItemModel(title: "Food Stories", count: 20, image: "food"))
//        return tilesArraytem
//    }()
    
    fileprivate var triviaHome = TriviaHome()

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        gridWidth = (UIScreen.main.bounds.width - titleViewHeight) / 2.0
        gridHeight = gridWidth + titleViewHeight
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()//collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: gridWidth, height: gridHeight)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        collectionView.collectionViewLayout = layout
        getTrivia()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true, titleInLeft: false, backImageColor: .red)
        self.navigationItem.hidesBackButton = true
    }
    
    // MARK: - Get trivia home data from server -
    private func getTrivia() {
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
        return triviaHome.Trivia_category.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? GridCollectionViewCell {
            if indexPath.row == 0 {
                let celldata1 = triviaHome.Trivia_daily
                cell.configureCell(celldata1.Title, coverImage: celldata1.Image, count: celldata1.Post_count, gridWidth: gridWidth, gridHeight: gridHeight, titleViewHeight: titleViewHeight, row: indexPath.row)
            } else {
                let cellData = triviaHome.Trivia_category[indexPath.row - 1]
                cell.configureCell(cellData.Category_name, coverImage: cellData.Category_image, count: cellData.Post_count, gridWidth: gridWidth, gridHeight: gridHeight, titleViewHeight: titleViewHeight, row: indexPath.row)
            }
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegate -
extension TriviaViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let myobject = UIStoryboard(name: Constants.Storyboard.trivia, bundle: nil).instantiateViewController(withIdentifier: "TRPostViewController") as? TRPostViewController {
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
            return CGSize(width: gridWidth*2, height: gridHeight)
        }
        return CGSize(width: gridWidth, height: gridHeight)
    }
}
