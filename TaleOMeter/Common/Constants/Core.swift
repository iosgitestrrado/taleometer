//
//  Core.swift
//  TaleOMeter
//
//  Created by Durgesh on 15/02/22.
//

import Foundation
import SystemConfiguration
import NVActivityIndicatorView
import UIKit

class Core: NSObject {
    private var activityIndicatorView: NVActivityIndicatorView?
    
    /* Loading progress bar remove from view */
    static func showProgress(viewV: UIView, activityIndicator: inout NVActivityIndicatorView) {
        let xAxis = (viewV.frame.size.width / 2.0)
        let yAxis = (viewV.frame.size.height / 2.0)

        let frame = CGRect(x: (xAxis - 17.5), y: (yAxis - 17.5), width: 35.0, height: 35.0)
        activityIndicator = NVActivityIndicatorView(frame: frame)
        activityIndicator.type = .ballPulse // add your type
        activityIndicator.color = .black // add your color
        activityIndicator.tag = 9566
        //        NVActivityIndicatorPresenter.sharedInstance.setMessage("Fetching Data...")
        viewV.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }

    static func hideProgress(activityIndicator: NVActivityIndicatorView) {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    /*
     * Push to another view controller using navigation controller
     */
    static func push(_ controller: UIViewController, storyboard: String, storyboardId: String) {
        let myobject = UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: storyboardId)
        (controller.sideMenuController?.rootViewController as! UINavigationController).pushViewController(myobject, animated: true)
    }
    
    /*
     * Present to another view controller using navigation controller
     */
    static func present(_ controller: UIViewController, storyboard: String, storyboardId: String) {
        let myobject = UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: storyboardId)
        (controller.sideMenuController?.rootViewController as! UINavigationController).present(myobject, animated: true, completion: nil)
    }
    
    /*
     * Get controller using storyboardId
     */
    static func getController(_ storyboard: String, storyboardId: String) -> UIViewController {
        return UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: storyboardId)
    }

    /*
     * Show/Hide navigationbar when view will apear.
     * Swap menu option enable/disable.
     * From UIController
     */
    static func showNavigationBar(cont: UIViewController, setNavigationBarHidden: Bool, isRightViewEnabled: Bool) {
        cont.sideMenuController?.isRightViewEnabled = isRightViewEnabled
        cont.navigationController?.setNavigationBarHidden(setNavigationBarHidden, animated: true)
        //cont.navigationController?.navigationBar.barTintColor = .white
        cont.navigationController?.navigationBar.tintColor = .white
        //cont.navigationController?.navigationBar.isTranslucent = false
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        cont.navigationController?.navigationBar.titleTextAttributes = textAttributes
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)
        cont.navigationItem.backBarButtonItem = backButton
    }
    
    
    /*
     *  Custom Bottom tabbar for application
     *  Add custom bottom tabbar to view
     */
    static func addBottomTabBar(_ view: UIView) {
        if let myobject = UIStoryboard(name: Storyboard.dashboard, bundle: nil).instantiateViewController(withIdentifier: "FooterViewController") as? FooterViewController {
            myobject.view.shadow = true
            myobject.homeButton.addShadow(shadowColor: UIColor.white.cgColor, shadowOffset: CGSize(width: 1.0, height: 1.0), shadowOpacity: 0.5, shadowRadius: 10.0)
            myobject.view.frame = CGRect(x: 40.0, y: view.frame.size.height - ((80.0 * UIScreen.main.bounds.size.height) / 667.0) , width: view.frame.size.width - 80.0, height: 60.0)
            view.addSubview(myobject.view)
        }
    }
}
