//
//  SegmentViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit

class SegmentViewController: UIViewController {

    // MARK: - Public Properties -
    var parentController: UIViewController?
    var parentFrame: CGRect?
    
    // MARK: - Private Properties -
    private var containerVC: ContainerViewController?
    private var viewsArray = [UIViewController]()
    private var genreList = [Genre]()
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.genreList.count <= 0 {
            getGenres()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.containerVC?.view.frame.size.width = self.parentFrame!.size.width
        self.containerVC?.view.frame.size.height = self.parentFrame!.size.height
    }
    
    // MARK: - Get Genres from API's -
    private func getGenres() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        Core.ShowProgress(parentController!, detailLbl: "")
        GenreClient.getData { result in
            if let response = result {
                self.genreList = response
                self.addContainerViews()
            }
            Core.HideProgress(self.parentController!)
        }
    }
    
    // MARK: - Add views into container -
    private func addContainerViews() {
        
        var gridView = GridViewController()
        for genre in genreList {
            gridView =  Core.getController(Constants.Storyboard.dashboard, storyboardId: "GridViewController") as! GridViewController
            gridView.parentController = self.parentController
            gridView.parentFrame = self.parentFrame
            gridView.title = genre.Name
            gridView.genreId = genre.Id
            gridView.totalGenres = genreList.count
            viewsArray.append(gridView)
        }
        
        self.containerVC = ContainerConstant.addContainerTo(self, containerControllers: viewsArray as NSArray, menuIndicatorColor: .red, menuItemTitleColor: .white, menuItemSelectedTitleColor: .red, menuBackGroudColor: .clear, font: UIFont.systemFont(ofSize: 14.0), menuViewWidth: self.parentFrame?.size.width ?? 320)
        self.containerVC?.view.frame.size.width = self.parentFrame!.size.width
        self.containerVC?.view.frame.size.height = self.parentFrame!.size.height
        self.containerVC?.delegate = self
    }
}


// MARK: - ContainerVCDelegate -
extension SegmentViewController: ContainerVCDelegate {
    func containerViewItem(_ index: NSInteger, currentController: UIViewController) {
        if let grid = currentController as? GridViewController {
            grid.loadAudioList()
        }
    }
}
