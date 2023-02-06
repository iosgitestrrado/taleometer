//
//  StorySegmentViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 24/02/22.
//

import UIKit

class StorySegmentViewController: UIViewController {
    
    // MARK: - Public Properties -
    var parentController: UIViewController?
    var parentFrame: CGRect?
    
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
    
    // MARK: - Add views into container -
    private func addContainerViews() {
        var storyView = Core.getController(Constants.Storyboard.other, storyboardId: "StoryViewController") as! StoryViewController
        storyView.title = "English"
        storyView.parentController = self
        //gridView.parentController = self.parentController
        viewsArray.append(storyView)
        
        storyView = Core.getController(Constants.Storyboard.other, storyboardId: "StoryViewController") as! StoryViewController
        storyView.parentController = self
//        storyView = Core.getController(Constants.Storyboard.other, storyboardId: "UserStoryViewController") as! UserStoryViewController
        //gridView.parentController = self.parentController
        storyView.title = "தமிழ்"
        viewsArray.append(storyView)
        
        self.containerVC = ContainerConstant.addContainerTo(self, containerControllers: viewsArray as NSArray, menuIndicatorColor: .red, menuItemTitleColor: .white, menuItemSelectedTitleColor: .red, menuBackGroudColor: .clear, font: UIFont.systemFont(ofSize: 14.0), menuViewWidth: 200.0)
        self.containerVC?.delegate = self
    }
}

// MARK: - ContainerVCDelegate -
extension StorySegmentViewController: ContainerVCDelegate {
    func containerViewItem(_ index: NSInteger, currentController: UIViewController) {
        if let grid = currentController as? StoryViewController {
            grid.getUserStory()
        }
    }
}
