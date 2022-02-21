//
//  FooterManager.swift
//  TaleOMeter
//
//  Created by Durgesh on 18/02/22.
//

import UIKit

class FooterManager: NSObject {
    // MARK: - Static Properties -
    static let shared = FooterManager()
    static let viewTag = 99999996
    
    // MARK: - Public Properties -
    public var isActive = false
    
    /*
     *  Custom Footer tabbar for application
     *  Add custom Footer to view
     */
    static func addFooter(_ controller: UIViewController, bottomConstraint: NSLayoutConstraint) {
        if let myobject = UIStoryboard(name: Storyboard.dashboard, bundle: nil).instantiateViewController(withIdentifier: "FooterViewController") as? FooterViewController {
            if let footerView = controller.view.viewWithTag(FooterManager.viewTag) {
                footerView.removeFromSuperview()
            }
            myobject.view.shadow = true
            myobject.view.tag = FooterManager.viewTag
            myobject.view.addShadow(shadowColor: UIColor.black.cgColor, shadowOffset: CGSize(width: 1.0, height: 1.0), shadowOpacity: 0.75)
            myobject.homeButton.shadow = true
            myobject.homeButton.addShadow(shadowColor: UIColor.red.cgColor, shadowOffset: CGSize(width: 5.0, height: 5.0), shadowOpacity: 0.5, shadowRadius: 10.0)

            myobject.view.frame = CGRect(x: 40.0, y: controller.view.frame.size.height - 80.0, width: controller.view.frame.size.width - 80.0, height: 60.0)
            
            bottomConstraint.constant = UIScreen.main.bounds.size.height -  myobject.view.frame.origin.y
//            if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first {
//                bottomConstraint.constant = UIScreen.main.bounds.size.height -  (myobject.view.frame.origin.y - window.safeAreaInsets.bottom)
//            }
            FooterManager.shared.isActive = true
            controller.view.addSubview(myobject.view)
        }
    }
}
