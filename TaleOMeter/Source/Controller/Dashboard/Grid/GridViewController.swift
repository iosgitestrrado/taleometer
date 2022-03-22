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
    @IBOutlet weak var collectionView: UICollectionView!
    var parentController: UIViewController?
    var parentFrame: CGRect?
    var genreId = -1
    var totalGenres = 0
    
    // MARK: - Private Properties -
    private var gridSize: CGFloat = 100.0
    private var audioList = [Audio]()
    private var currentIndex = -1
    private var pageNumber = 1
    private var morepage = true
    private var pageLimit = 9

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Set collection view frame
        self.collectionView.frame.size.width = parentFrame!.size.width
        if genreId < 0 {
            currentIndex = 0
            self.collectionView.reloadData()
            return
        }
        
        // Set page limit as per Genre
        pageLimit = pageLimit * totalGenres
        
        // Enable vertical scroll always
        self.collectionView.alwaysBounceVertical = true
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
            // Set infinite scroll
            let indicatorRect: CGRect = CGRect(x: 0, y: 0, width: 24, height: 24)
            self.collectionView.infiniteScrollIndicatorView = CustomInfiniteIndicator(frame: indicatorRect)
            
            // Set custom indicator margin
            collectionView?.infiniteScrollIndicatorMargin = 40
            
            collectionView?.addInfiniteScroll { [weak self] (scrollView) -> Void in
                self?.getAudioList({
                    scrollView.finishInfiniteScroll()
                })
            }
            
            // load initial data
            collectionView?.beginInfiniteScroll(true)
        }
    }
    
    private func getAudioList(_ completionHandler: (() -> Void)?) {
        if !Reachability.isConnectedToNetwork() {
            Toast.show()
            return
        }
        if !morepage {
            return
        }
        Core.ShowProgress(parentController!, detailLbl: "Getting Audio...")
            AudioClient.get(AudioRequest(page: pageNumber, limit: pageLimit), genreId: genreId, completion: { [self] result in
                morepage = result != nil && result!.count > 0
                if let response = result, response.count > 0 {
                    if pageNumber == 1 {
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
                        currentIndex = 0
                        pageNumber += 1
                    }
                    
                    let newItems = response
                    
                    // create new index paths
                    let photoCount = self.audioList.count
                    let (start, end) = (photoCount, newItems.count + photoCount)
                    let indexPaths = (start..<end).map { return IndexPath(row: $0, section: 0) }
                    
                    // update data source
                    self.audioList.append(contentsOf: newItems)
                                                
                    // update collection view
                    self.collectionView?.performBatchUpdates({ () -> Void in
                        self.collectionView?.insertItems(at: indexPaths)
                    }, completion: { (finished) -> Void in
                        completionHandler?()
                        Core.HideProgress(parentController!)
                        return
                    });
                }
                completionHandler?()
                Core.HideProgress(parentController!)
            })
    }
    
    // MARK: - Actions
    @IBAction func handleRefresh() {
        collectionView?.beginInfiniteScroll(true)
    }
}

// MARK: - UICollectionViewDataSource -
extension GridViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return audioList.count > 0 ?  audioList.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if audioList.count > 0 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gridCell", for: indexPath) as? GridCollecViewCell {
                cell.imageView.image = audioList[indexPath.row].Image
                cell.imageView.frame = CGRect(x: 25.0, y: 5.0, width: gridSize - 40.0, height: gridSize - 40.0)
                cell.imageView.cornerRadius = cell.imageView.frame.size.width / 2.0
                
                let labelY = cell.imageView.frame.origin.y + cell.imageView.frame.size.height + 16.0
                cell.titleLabel.text = audioList[indexPath.row].Title
                cell.titleLabel.frame = CGRect(x: 0, y: labelY, width: gridSize, height: gridSize - labelY + 14.0)
                return cell
            }
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noData", for: indexPath) as? GridCollecViewCell {
                
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
                        Toast.show("Audio File \"\(fileName.pathExtension)\" is not supported!")
                        return
                    }
                }
                if AudioPlayManager.shared.isNonStop {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "closeMiniPlayer"), object: nil)
                }
                AudioPlayManager.shared.audioList = audioList
                AudioPlayManager.shared.setAudioIndex(indexPath.row ,isNext: false)
                parentController!.navigationController?.pushViewController(myobject, animated: true)
            }
        } else {
            Core.push(self.parentController!, storyboard: Constants.Storyboard.auth, storyboardId: "LoginViewController")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if indexPath.row == collectionView.numberOfItems(inSection: indexPath.section) - 1 {
//            getAudioList()
//        }
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
        if audioList.count > 0 {
            gridSize = (UIScreen.main.bounds.width - (60.0 * UIScreen.main.bounds.width) / 390.0) / 3.0
        } else {
            gridSize = parentFrame!.size.width
        }
        return CGSize(width:  currentIndex >= 0 ? gridSize : 0, height: audioList.count > 0 ? gridSize : (currentIndex >= 0 ? 30.0 : 0.0))
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 1
//    }
}
