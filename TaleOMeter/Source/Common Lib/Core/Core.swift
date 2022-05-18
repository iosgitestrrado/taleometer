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
import NVActivityIndicatorView

class Core: NSObject {
    static var activityIndicator: NVActivityIndicatorView = NVActivityIndicatorView(frame: CGRect.zero)
    
    // MARK: - Static Functions -
    /*
     * Push to another view controller using navigation controller
     */
    static func push(_ controller: UIViewController, storyboard: String, storyboardId: String, animated: Bool = true) {
        if let navLastChild = controller.navigationController?.children.last, navLastChild.className != storyboardId {
            let myobject = UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: storyboardId)
            controller.navigationController?.pushViewController(myobject, animated: animated)
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
     * Push to no internet connection view
     */
    static func noInternet(_ controller: UIViewController, methodName: String = "") {
        if let myobject = UIStoryboard(name: Constants.Storyboard.other, bundle: nil).instantiateViewController(withIdentifier: "NoInternetViewController") as? NoInternetViewController {
            myobject.delegate = controller as? NoInternetDelegate
            myobject.methodName = methodName
            controller.navigationController?.pushViewController(myobject, animated: true)
        }
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
    static func showNavigationBar(cont: UIViewController, setNavigationBarHidden: Bool, isRightViewEnabled: Bool, titleInLeft: Bool = true, backImage: Bool = false, backImageColor: UIColor = .white, bigfont: Bool = false) {
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
        if let textContainer = window.viewWithTag(9998) {
            textContainer.removeFromSuperview()
        }
        cont.sideMenuController?.isRightViewEnabled = isRightViewEnabled
        cont.navigationController?.setNavigationBarHidden(setNavigationBarHidden, animated: true)
        //cont.navigationController?.navigationBar.barTintColor = .clear
        //cont.navigationController?.navigationBar.tintColor = .clear
        cont.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
        cont.navigationController?.navigationBar.shadowImage = UIImage()
        cont.navigationController?.navigationBar.isTranslucent = true
        cont.navigationController?.view.backgroundColor = .clear
        
//        for family in UIFont.familyNames.sorted() {
//            let names = UIFont.fontNames(forFamilyName: family)
//            print("Family: \(family) Font names: \(names)")
//        }
        
        if bigfont {
            guard let customFont = UIFont(name: "CommutersSans-Bold", size: 25.0) else {
                fatalError("""
                    Failed to load the "CommutersSans-Bold" font.
                    Make sure the font file is included in the project and the font name is spelled correctly.
                    """
                )
            }
            let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: customFont]
            cont.navigationController?.navigationBar.titleTextAttributes = textAttributes
        } else {
            let textAttributes1 = [NSAttributedString.Key.foregroundColor: UIColor.white]
            cont.navigationController?.navigationBar.titleTextAttributes = textAttributes1
        }

        if !setNavigationBarHidden && cont.navigationController?.children[(cont.navigationController?.children.count)! - 2] is LaunchViewController {
            if storyId != -1 {
                if let dash = UIStoryboard(name: Constants.Storyboard.dashboard, bundle: nil).instantiateViewController(withIdentifier: DashboardViewController().className) as? DashboardViewController, var navViewControllers = cont.navigationController?.viewControllers {
                    navViewControllers.insert(dash, at: navViewControllers.count - 1)
                    cont.navigationController?.viewControllers = navViewControllers
                }
            } else if categorId != -1 {
                if let dashTrivia = UIStoryboard(name: Constants.Storyboard.trivia, bundle: nil).instantiateViewController(withIdentifier: TriviaViewController().className) as? TriviaViewController, var navViewControllers = cont.navigationController?.viewControllers {
                    navViewControllers.insert(dashTrivia, at: navViewControllers.count - 1)
                    cont.navigationController?.viewControllers = navViewControllers
                }
            } else {
                cont.navigationItem.hidesBackButton = true
            }
            if cont is RegisterViewController || cont is PreferenceViewController {
                cont.navigationController?.setNavigationBarHidden(true, animated: true)
            }
        }
        cont.navigationController?.navigationBar.tintColor = .red
        if storyId != -1 {
            cont.navigationController?.navigationBar.tintColor = .clear
            storyId = -2
        }
//        var backImageI = UIImage(systemName: "chevron.backward")
//        if backImage {
//            backImageI =  UIImage(named: "back_red")
//        }
        cont.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back_red")
        cont.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back_red")
        let backButton = UIBarButtonItem(title: " ", style: UIBarButtonItem.Style.plain, target: self, action: nil)
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
    
//    /* Loading progress bar add to view */
//    static func ShowProgress(_ target: UIViewController, detailLbl: String) {
//        let spinnerActivity = MBProgressHUD.showAdded(to: target.view, animated: true)
//        spinnerActivity.label.text = ""//"Loading"
//        spinnerActivity.detailsLabel.text = ""//detailLbl.isBlank ? "Please Wait..." : detailLbl
//        spinnerActivity.bezelView.backgroundColor = .clear
//        spinnerActivity.tintColor = .red
//        spinnerActivity.isUserInteractionEnabled = true
//    }
//
//    /* Loading progress bar remove from view */
//    static func HideProgress(_ target: UIViewController) {
//        DispatchQueue.main.async {
//            MBProgressHUD.hide(for: target.view, animated: true)
//        }
//    }
    
    static func ShowProgress(_ target: UIViewController, detailLbl: String) {
        if let indc = target.view.viewWithTag(9566) {
            indc.removeFromSuperview()
        }
        activityIndicator.removeFromSuperview()
        let xAxis = (target.view.frame.size.width / 2.0)
        let yAxis = (target.view.frame.size.height / 2.0)

        let frame = CGRect(x: (xAxis - 50.0), y: (yAxis - 50.0), width: 100.0, height: 100.0)
        activityIndicator = NVActivityIndicatorView(frame: frame)
        activityIndicator.type = .ballRotateChase//.ballSpinFadeLoader // add your type
        activityIndicator.color = UIColor(displayP3Red: 213.0 / 255.0, green: 40.0 / 255.0, blue: 54.0 / 255.0, alpha: 1.0) // add your color
        activityIndicator.tag = 9566
        //        NVActivityIndicatorPresenter.sharedInstance.setMessage("Fetching Data...")
        target.view.addSubview(activityIndicator)
        target.view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
    }

    static func HideProgress(_ target: UIViewController) {
        DispatchQueue.main.async {
            target.view.isUserInteractionEnabled = true
            if let indc = target.view.viewWithTag(9566) {
                indc.removeFromSuperview()
            }
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
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
    
    
    /*
     Set image using url
     */
    static func setImage(_ url: String, image: inout UIImage) {
        if let url = URL(string: url) {
            do {
                let data = try Data(contentsOf: url)
                image = UIImage(data: data) ?? defaultImage
            } catch {
                image = defaultImage
            }
        } else {
            image = defaultImage
        }
    }
    
    /*
     Check it is a URL or not
     */
    static func verifyUrl(_ urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    /*
     Initialize footer view for table view lazy load
     */
    // MARK: - Initialize table footer view
    static func initFooterView(_ target: UIViewController, footerView: inout UIView) {
        footerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: Double(target.view.frame.size.width), height: 60.0))

        let frame = CGRect(x: (target.view.frame.size.width / 2.0) - 30.0, y: 5.0, width: 60.0, height: 60.0)
        let activityIndicator = NVActivityIndicatorView(frame: frame)
        activityIndicator.tag = 10
        activityIndicator.type = .ballSpinFadeLoader// .ballRotateChase // add your type
        activityIndicator.color = UIColor(displayP3Red: 213.0 / 255.0, green: 40.0 / 255.0, blue: 54.0 / 255.0, alpha: 1.0) // add your color
        activityIndicator.tag = 9566
        activityIndicator.startAnimating()
        
        footerView.addSubview(activityIndicator)
        footerView.isHidden = false
    }
    
    // MARK: - Share to social -
    static func shareContent(_ target: UIViewController, displayName: String, completion: @escaping(Bool?) -> Void) {
//        let content = "Introducing tale'o'meter, An App that simplifies for Every One. \nClick here to download application http://onelink.to/gaypyh"
        let content = "Take a pause! Breathe a little! Challenge yourself!\nTale’o’meter…. The audio OTT… Original Tamil Tales Signup for free.\nLet’s take the daily break we deserve. I play this daily as \(displayName)"
        
        let controller = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        controller.excludedActivityTypes = [.postToTwitter, .postToFacebook, .postToWeibo, .message, .mail, .print, .copyToPasteboard, .assignToContact, .saveToCameraRoll, .addToReadingList, .postToVimeo, .postToFlickr, .postToTencentWeibo, .airDrop, .markupAsPDF, .openInIBooks]
        controller.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            completion(completed)
         }
        target.present(controller, animated: true) {
            
        }
       // target.present(controller, animated: true, completion: nil)
    }
}
