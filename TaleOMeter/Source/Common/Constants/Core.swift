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
        controller.navigationController?.pushViewController(myobject, animated: true)
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
    static func showNavigationBar(cont: UIViewController, setNavigationBarHidden: Bool, isRightViewEnabled: Bool, titleInLeft: Bool = true) {
        cont.sideMenuController?.isRightViewEnabled = isRightViewEnabled
        cont.navigationController?.setNavigationBarHidden(setNavigationBarHidden, animated: true)
        //cont.navigationController?.navigationBar.barTintColor = .white
        cont.navigationController?.navigationBar.tintColor = .white
        //cont.navigationController?.navigationBar.isTranslucent = false
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        cont.navigationController?.navigationBar.titleTextAttributes = textAttributes
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)
        cont.navigationItem.backBarButtonItem = backButton
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
}
