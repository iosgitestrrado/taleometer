//
//  FooterManager.swift
//  TaleOMeter
//
//  Created by Durgesh on 18/02/22.
//  Copyright © 2022 Durgesh. All rights reserved.
//

import UIKit

class FooterManager: NSObject {
    // MARK: - Static Properties -
    static let shared = FooterManager()
    static let viewTag = 99999996
    
    // MARK: - Public Properties -
    var isActive = false
    
    // MARK: - Private Properties -
    private var curVController = UIViewController()
//    private var searchDotStackView = UIStackView()
//    private var favDotStackView = UIStackView()

    /*
     *  Custom Footer tabbar for application
     *  Add custom Footer to view
     */
    static func addFooter(_ controller: UIViewController, bottomConstraint: NSLayoutConstraint = NSLayoutConstraint(), isFavorite: Bool = false, isSearch: Bool = false) {
        if let myobject = UIStoryboard(name: Constants.Storyboard.dashboard, bundle: nil).instantiateViewController(withIdentifier: "FooterViewController") as? FooterViewController {
            if let footerView = controller.view.viewWithTag(FooterManager.viewTag) {
                footerView.removeFromSuperview()
            }
            myobject.parentController = controller
            FooterManager.shared.curVController = controller
            myobject.view.shadow = true
            myobject.view.tag = FooterManager.viewTag
            myobject.view.addShadow(shadowOffset: CGSize(width: 1.0, height: 1.0), shadowOpacity: 0.75)

            myobject.view.frame = CGRect(x: 40.0, y: controller.view.frame.size.height - 80.0, width: controller.view.frame.size.width - 80.0, height: 60.0)
            
            myobject.homeButton.addTarget(FooterManager.shared.self, action: #selector(tapOnHome(_:)), for: .touchUpInside)
            myobject.searchButton.addTarget(FooterManager.shared.self, action: #selector(tapOnSearch(_:)), for: .touchUpInside)
            myobject.favStackView.isHidden = !isFavorite
            myobject.searchStackView.isHidden = !isSearch
//            FooterManager.shared.favDotStackView = myobject.favStackView
//            FooterManager.shared.searchDotStackView = myobject.searchStackView
            myobject.favButton.addTarget(FooterManager.shared.self, action: #selector(tapOnFav(_:)), for: .touchUpInside)
            bottomConstraint.constant = UIScreen.main.bounds.size.height -  myobject.view.frame.origin.y
            if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first {
                bottomConstraint.constant = UIScreen.main.bounds.size.height -  (myobject.view.frame.origin.y + window.safeAreaInsets.bottom)
            }
            FooterManager.shared.isActive = true
            
            controller.view.addSubview(myobject.view)
        }
    }
    
    @objc func tapOnSearch(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "isLogin") {
            if let navControllers = curVController.navigationController?.children {
                for controller in navControllers {
                    if controller is SearchViewController {
                        curVController.navigationController?.popToViewController(controller, animated: true)
                        return
                    }
                }
            }
            Core.push(curVController, storyboard: Constants.Storyboard.audio, storyboardId: "SearchViewController")
        } else {
            Core.push(curVController, storyboard: Constants.Storyboard.auth, storyboardId: "LoginViewController")
        }
    }
    
    @objc func tapOnFav(_ sender: Any) {
        //Core.present(curVController, storyboard: Storyboard.audio, storyboardId: "CommingViewController")
        if UserDefaults.standard.bool(forKey: "isLogin") {
            if let navControllers = curVController.navigationController?.children {
                for controller in navControllers {
                    if controller is FavouriteViewController {
                        curVController.navigationController?.popToViewController(controller, animated: true)
                        return
                    }
                }
            }
            Core.push(curVController, storyboard: Constants.Storyboard.audio, storyboardId: "FavouriteViewController")
        } else {
            Core.push(curVController, storyboard: Constants.Storyboard.auth, storyboardId: "LoginViewController")
        }
    }
    
    @objc func tapOnHome(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "isLogin") {
            if let navControllers = curVController.navigationController?.children {
                for controller in navControllers {
                    if controller is DashboardViewController {
                        curVController.navigationController?.popToViewController(controller, animated: true)
                        return
                    }
                }
            }
            Core.push(curVController, storyboard: Constants.Storyboard.dashboard, storyboardId: "DashboardViewController")
        } else {
            Core.push(curVController, storyboard: Constants.Storyboard.auth, storyboardId: "LoginViewController")
        }
    }
}
