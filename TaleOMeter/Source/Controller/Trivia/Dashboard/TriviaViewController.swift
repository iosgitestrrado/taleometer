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
    private var gridWidth: CGFloat = 187.0
    private var gridHeight: CGFloat = 225.0
    private var titleViewHeight: CGFloat = 50.0

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true, titleInLeft: false)
        self.navigationItem.hidesBackButton = true
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
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? GridCollectionViewCell {
            
            cell.imageView.image = UIImage(named: "Default_img")
            if indexPath.row == 0 {
                cell.imageView.frame = CGRect(x: 0.0, y: 0.0, width: gridWidth * 2, height: gridHeight - titleViewHeight)
                cell.titleView.frame = CGRect(x: 0.0, y: gridHeight - titleViewHeight, width: gridWidth * 2, height: titleViewHeight)
            } else {
                cell.imageView.frame = CGRect(x: 0.0, y: 0.0, width: gridWidth, height: gridHeight - titleViewHeight)
                cell.titleView.frame = CGRect(x: 0.0, y: gridHeight - titleViewHeight, width: gridWidth, height: titleViewHeight)
                cell.titleLabel.frame = CGRect(x: 15.0, y: 0.0, width: gridWidth - 15.0, height: titleViewHeight)
            }
            cell.titleLabel.text = "Tract To Relax"
            
            cell.titleView.layer.cornerRadius = 20
            cell.titleView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegate -
extension TriviaViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
