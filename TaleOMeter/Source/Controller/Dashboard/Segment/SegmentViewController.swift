//
//  SegmentViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit

class SegmentViewController: UIViewController {

    // MARK: - Public Properties -
    public var parentController: UIViewController?
    public var parentFrame: CGRect?
    
    // MARK: - Private Properties -
    private var containerVC: ContainerViewController?
    private var viewsArray = [UIViewController]()
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addContainerViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.view.frame.size.height = (parentFrame?.size.height)!
        //self.view.frame.size.width = (parentFrame?.size.width)!
    }
    
    // MARK: - Add views into container -
    private func addContainerViews() {
        var gridView = Core.getController(Storyboard.dashboard, storyboardId: "GridViewController") as! GridViewController
        gridView.title = "Entertain"
        gridView.parentController = self.parentController
        viewsArray.append(gridView)
        
        gridView = Core.getController(Storyboard.dashboard, storyboardId: "GridViewController") as! GridViewController
        gridView.parentController = self.parentController
        gridView.title = "Inspire"
        viewsArray.append(gridView)
        
        for _ in 0..<20 {
            gridView = Core.getController(Storyboard.dashboard, storyboardId: "GridViewController") as! GridViewController
            gridView.parentController = self.parentController
            gridView.title = "Snooze"
            viewsArray.append(gridView)
        }
        
        self.containerVC = ContainerConstant.addContainerTo(self, containerControllers: viewsArray as NSArray, menuIndicatorColor: .red, menuItemTitleColor: .white, menuItemSelectedTitleColor: .red, menuBackGroudColor: .clear, font: UIFont.systemFont(ofSize: 14.0), menuViewWidth: self.parentFrame?.size.width ?? 320)
    }
}
