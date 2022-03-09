//
//  GridViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit

class GridViewController: UIViewController {

    // MARK: - Public Properties -
    @IBOutlet weak var collectionView: UICollectionView!
    var parentController: UIViewController?
    var parentFrame: CGRect?
    var genreId = -1
    
    // MARK: - Private Properties -
    private var gridSize: CGFloat = 100.0
    private var audioList = [Audio]()

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //self.collectionView.frame = CGRect(x: 0, y: 0, width: parentFrame!.size.width - 50.0, height: parentFrame!.size.height)
//        gridSize = 100//(self.collectionView.frame.size.width - 40.0) / 3.0
//        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
//        layout.itemSize = CGSize(width: gridSize, height: gridSize)
//        layout.minimumInteritemSpacing = 0
//        layout.minimumLineSpacing = 0
//        collectionView!.collectionViewLayout = layout
        if genreId >= 0 {
            getAudioList()
        }
    }
    
    private func getAudioList() {
        Core.ShowProgress(parentController!, detailLbl: "Getting Audio...")
        AudioClient.get(AudioRequest(page: 1, limit: 10), genreId: genreId, completion: { [self] result in
            if let response = result {
                audioList = response
                self.collectionView.reloadData()
            }
            Core.HideProgress(parentController!)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: - UICollectionViewDataSource -
extension GridViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return audioList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gridCell", for: indexPath) as? GridCollectionViewCell {
            
            cell.imageView.image = audioList[indexPath.row].Image
//            cell.imageView.frame = CGRect(x: 20.0, y: 8.0, width: 60, height: 60)
//            cell.imageView.cornerRadius = (gridSize - 40.0) / 2.0
            
           // let labelY = cell.imageView.frame.origin.y + cell.imageView.frame.size.height + 2.0
            cell.titleLabel.text = audioList[indexPath.row].Title
            //cell.titleLabel.frame = CGRect(x: 8.0, y: labelY, width: gridSize - 16.0, height: gridSize - labelY)
            
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegate -
extension GridViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if UserDefaults.standard.bool(forKey: Constants.UserDefault.IsLogin) {
            //Core.push(self.parentController!, storyboard: Constants.Storyboard.audio, storyboardId: "NowPlayViewController")
            if let myobject = UIStoryboard(name: Constants.Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "NowPlayViewController") as? NowPlayViewController {
                myobject.audio = audioList[indexPath.row]
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

// MARK: - UICollectionViewDelegateFlowLayout -
extension GridViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return uic
//    }
}
