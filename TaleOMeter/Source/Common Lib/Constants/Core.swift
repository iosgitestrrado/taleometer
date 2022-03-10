//
//  Core.swift
//  TaleOMeter
//
//  Created by Durgesh on 15/02/22.
//  Copyright © 2022 Durgesh. All rights reserved.
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
        if let navLastChild = controller.navigationController?.children.last, navLastChild.className != storyboardId {
            let myobject = UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: storyboardId)
            controller.navigationController?.pushViewController(myobject, animated: true)
        }
    }
    
    /*
     * Present to another view controller using navigation controller
     */
    static func present(_ controller: UIViewController, storyboard: String, storyboardId: String) {
        let myobject = UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: storyboardId)
        controller.navigationController?.present(myobject, animated: true, completion: nil)
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
    static func showNavigationBar(cont: UIViewController, setNavigationBarHidden: Bool, isRightViewEnabled: Bool, titleInLeft: Bool = true, backImage: Bool = false) {
      
        cont.sideMenuController?.isRightViewEnabled = isRightViewEnabled
        cont.navigationController?.setNavigationBarHidden(setNavigationBarHidden, animated: true)
        //cont.navigationController?.navigationBar.barTintColor = .clear
        //cont.navigationController?.navigationBar.tintColor = .clear
        cont.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
        cont.navigationController?.navigationBar.shadowImage = UIImage()
        cont.navigationController?.navigationBar.isTranslucent = true
        cont.navigationController?.view.backgroundColor = .clear
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        cont.navigationController?.navigationBar.titleTextAttributes = textAttributes
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)
        cont.navigationItem.backBarButtonItem = backButton

        if backImage {
            let yourBackImage = UIImage(systemName: "arrow.backward")
            cont.navigationController?.navigationBar.backIndicatorImage = yourBackImage
            cont.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        } else {
            let defaultImage = UIImage(systemName: "chevron.backward")
            cont.navigationController?.navigationBar.backIndicatorImage = defaultImage
            cont.navigationController?.navigationBar.backIndicatorTransitionMaskImage = defaultImage
        }
        if !setNavigationBarHidden && cont.navigationController?.children[(cont.navigationController?.children.count)! - 2] is LaunchViewController {
            cont.navigationItem.hidesBackButton = true
        }
        if titleInLeft, let titleStr = cont.navigationItem.title {
            Core.setLeftAlignTitleView(controller: cont, text: titleStr, textColor: .white)
        }
    }
    
    static func setLeftAlignTitleView(controller: UIViewController, text: String, textColor: UIColor) {
        guard let navFrame = controller.navigationController?.navigationBar.frame else{
            return
        }
        
        let parentView = UIView(frame: CGRect(x: 0, y: 0, width: navFrame.width*3, height: navFrame.height))
        controller.navigationItem.titleView = parentView
        
        let label = UILabel(frame: .init(x: parentView.frame.minX, y: parentView.frame.minY, width: parentView.frame.width, height: parentView.frame.height))
        label.backgroundColor = .clear
        label.numberOfLines = 2
        label.textAlignment = .left
        label.textColor = textColor
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        
        parentView.addSubview(label)
    }
    
    /* Loading progress bar add to view */
    static func ShowProgress(_ target: UIViewController, detailLbl: String) {
        let spinnerActivity = MBProgressHUD.showAdded(to: target.view, animated: true)
        spinnerActivity.label.text = "Loading"
        spinnerActivity.detailsLabel.text = detailLbl.isBlank ? "Please Wait..." : detailLbl
        spinnerActivity.isUserInteractionEnabled = true
    }

    /* Loading progress bar remove from view */
    static func HideProgress(_ target: UIViewController) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: target.view, animated: true)
        }
    }
    
    /*
     * Convert image into attribute string for label
     */
    static func getImageString(_ name: String) -> NSMutableAttributedString
    {
        let attachment:NSTextAttachment = NSTextAttachment()
        attachment.image = UIImage(named: name)

        let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
        let myString:NSMutableAttributedString = NSMutableAttributedString(string: "")
        myString.append(attachmentString)
        return myString
    }
    
    /*
     * Convert System image into attribute string for label
     */
    static func getSysImageString(_ systemName: String) -> NSMutableAttributedString
    {
        let attachment:NSTextAttachment = NSTextAttachment()
        attachment.image = UIImage(systemName: systemName)?.maskWithColor(color: .white)

        let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
        let myString:NSMutableAttributedString = NSMutableAttributedString(string: "")
        myString.append(attachmentString)
        return myString
    }
    
    /**
     Express the postedDate in following format: "[x] [time period] ago"
     need to pass epochtime (since 1970)
     */
    static func soMuchTimeAgo(_ postedDate: Double) -> String {
        let diff = Date().timeIntervalSince1970 - postedDate
        var str: String = ""
        if  diff < 60 {
            str = "now"
        } else if diff < 3600 {
            let out = Int(round(diff/60))
            str = (out == 1 ? "1 minute ago" : "\(out) minutes ago")
        } else if diff < 3600 * 24 {
            let out = Int(round(diff/3600))
            str = (out == 1 ? "1 hour ago" : "\(out) hours ago")
        } else if diff < 3600 * 24 * 2 {
            str = "yesterday"
        } else if diff < 3600 * 24 * 7 {
            let out = Int(round(diff/(3600*24)))
            str = (out == 1 ? "1 day ago" : "\(out) days ago")
        } else if diff < 3600 * 24 * 7 * 4{
            let out = Int(round(diff/(3600*24*7)))
            str = (out == 1 ? "1 week ago" : "\(out) weeks ago")
        } else if diff < 3600 * 24 * 7 * 4 * 12{
            let out = Int(round(diff/(3600*24*7*4)))
            str = (out == 1 ? "1 month ago" : "\(out) months ago")
        } else {//if diff < 3600 * 24 * 7 * 4 * 12{
            let out = Int(round(diff/(3600*24*7*4*12)))
            str = (out == 1 ? "1 year ago" : "\(out) years ago")
        }
        return str
    }
    
    /**
        * Combile two image
     */
    static func combineImages(_ bottomImage: UIImage, topImage: UIImage) -> UIImage {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)

        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        bottomImage.draw(in: areaSize)

        topImage.draw(in: areaSize, blendMode: .normal, alpha: 1.0)

        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
