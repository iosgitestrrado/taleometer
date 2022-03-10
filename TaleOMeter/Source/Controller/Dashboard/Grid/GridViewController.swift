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
    var totalGenres = 0
    
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
        
        collectionView.frame.size.width = parentFrame!.size.width
        if genreId >= 0 {
            getAudioList()
        }
    }
    
    private func getAudioList() {
        Core.ShowProgress(parentController!, detailLbl: "Getting Audio...")
        AudioClient.get(AudioRequest(page: 1, limit: totalGenres * 12), genreId: genreId, completion: { [self] result in
            if let response = result {
                audioList = response
                let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)

                if audioList.count > 0 {
                    gridSize = (UIScreen.main.bounds.width - (60.0 * UIScreen.main.bounds.width) / 390.0) / 3.0
                    layout.itemSize = CGSize(width: gridSize, height: gridSize)
                    
                } else {
                    gridSize = parentFrame!.size.width
                    layout.itemSize = CGSize(width: gridSize, height: 30)
                }
                layout.minimumInteritemSpacing = 0
                layout.minimumLineSpacing = 10
                collectionView.collectionViewLayout = layout
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
        if audioList.count > 0 {
            return audioList.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if audioList.count > 0 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gridCell", for: indexPath) as? GridCollectionViewCell {
                
                cell.imageView.image = audioList[indexPath.row].Image
                cell.imageView.frame = CGRect(x: 25.0, y: 5.0, width: gridSize - 40.0, height: gridSize - 40.0)
                cell.imageView.cornerRadius = cell.imageView.frame.size.width / 2.0
                
                let labelY = cell.imageView.frame.origin.y + cell.imageView.frame.size.height + 16.0
                cell.titleLabel.text = audioList[indexPath.row].Title
                cell.titleLabel.frame = CGRect(x: 0, y: labelY, width: gridSize, height: gridSize - labelY + 14.0)
                return cell
            }
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noData", for: indexPath) as? GridCollectionViewCell {
                
                cell.titleLabel.text = "No Audio Founds!"
                cell.titleLabel.frame = CGRect(x: 0, y: 0, width: gridSize, height: 30)
                return cell
            }
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
                if let audioUrl = URL(string: audioList[indexPath.row].File) {
                    let fileName = NSString(string: audioUrl.lastPathComponent)
                    if !supportedAudioExtenstion.contains(fileName.pathExtension.lowercased()) {
                        Snackbar.showErrorMessage("Audio File \"\(fileName.pathExtension)\" is not supported!")
                        return
                    }
                }
                AudioPlayManager.shared.audioList = audioList
                AudioPlayManager.shared.currentAudio = indexPath.row
                AudioPlayManager.shared.nextAudio = audioList.count - 1 > indexPath.row ? indexPath.row + 1 : 0
                AudioPlayManager.shared.prevAudio = indexPath.row > 0 ? indexPath.row - 1 : audioList.count - 1                
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: gridSize, height: audioList.count > 0 ? gridSize : 30.0)
    }
}
