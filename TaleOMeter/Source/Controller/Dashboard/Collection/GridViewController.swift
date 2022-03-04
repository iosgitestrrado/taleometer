//
//  GridViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit

class GridViewController: UICollectionViewController {

    // MARK: - Public Properties -
    public var parentController: UIViewController?
    
    // MARK: - Private Properties -
    private var gridSize: CGFloat = 100.0
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        gridSize = (UIScreen.main.bounds.size.width - 40.0) / 3.0
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: gridSize, height: gridSize)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - UICollectionViewDataSource -
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 13
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gridCell", for: indexPath) as? GridCollectionViewCell {
            
            cell.imageView.image = UIImage(named: "logo")
            cell.imageView.frame = CGRect(x: 20.0, y: 8.0, width: gridSize - 40.0, height: gridSize - 40.0)
            cell.imageView.cornerRadius = (gridSize - 40.0) / 2.0
            
            let labelY = cell.imageView.frame.origin.y + cell.imageView.frame.size.height + 2.0
            cell.titleLabel.text = "Tract To Relax"
            cell.titleLabel.frame = CGRect(x: 8.0, y: labelY, width: gridSize - 16.0, height: gridSize - labelY)
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    // MARK: - UICollectionViewDelegate -
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if UserDefaults.standard.bool(forKey: "isLogin") {
            Core.push(self.parentController!, storyboard: Storyboard.audio, storyboardId: "NowPlayViewController")
        } else {
            Core.push(self.parentController!, storyboard: Storyboard.auth, storyboardId: "LoginViewController")
        }
    }
    
    // MARK: - UIScrollViewDelegate -
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
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

// MARK: - UICollectionViewDelegateFlowLayout -
extension GridViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 100.0, height: 100.0)
//    }
}
