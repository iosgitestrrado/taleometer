//
//  Core.swift
//  TaleOMeter
//
//  Created by Durgesh on 15/02/22.
//

import Foundation
import AVFoundation
import SystemConfiguration
import UIKit
import MBProgressHUD

class Core: NSObject {
    
    
    // MARK: - Static Functions -
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
    
    /* Loading progress bar add to view */
    static func ShowProgress(contrSelf: UIViewController, detailLbl: String) {
        let spinnerActivity = MBProgressHUD.showAdded(to: contrSelf.view, animated: true);
        spinnerActivity.label.text = "Loading";
        spinnerActivity.detailsLabel.text = detailLbl;
        spinnerActivity.isUserInteractionEnabled = true;
    }

    /* Loading progress bar remove from view */
    static func HideProgress(contrSelf: UIViewController) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: contrSelf.view, animated: true);
        }
    }
    
//    private var activityIndicatorView: NVActivityIndicatorView?

//    /* Loading progress bar add to view */
//    static func showProgress(detailLbl: String) {
//        let activityData = ActivityData()
//        var detailLbl1 = detailLbl
//        if detailLbl1.isEmpty {
//            detailLbl1 = "Please wait!!"
//        }
//        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
//        NVActivityIndicatorPresenter.sharedInstance.setMessage(detailLbl1)
//    }
//
//    /* Loading progress bar remove from view */
//    static func hideProgress() {
//        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
//    }
}
