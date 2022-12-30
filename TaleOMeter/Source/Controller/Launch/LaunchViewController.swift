//
//  LaunchViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 12/02/22.
//

import UIKit
import SwiftGifOrigin
import Firebase

class LaunchViewController: UIViewController {
    
    // MARK: - Weak Properties -
    @IBOutlet weak var splashImage: UIImageView!
    
    @IBOutlet weak var appGuideView: UIView! {
        didSet {
            self.appGuideView.isHidden = true
        }
    }
    @IBOutlet weak var guideScrollView: UIScrollView!
    @IBOutlet weak var AGskipButton: UIButton!
    @IBOutlet weak var AGNextButton: UIButton!
    @IBOutlet weak var AGLetsStart: UIButton!
    @IBOutlet weak var pageController: UIPageControl!
    
    private var totalImages = 3
    var showTutorial = false
    
    enum VersionError: Error {
        case invalidResponse, invalidBundleInfo
    }
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.splashImage.image = UIImage.gif(name: "splash_anim_new")
        if showTutorial {
            totalImages = 6
            self.showHideView(self.appGuideView, isHidden: false)
            AGLetsStart.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: true, isRightViewEnabled: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if showTutorial {
//            if UIScreen.main.bounds.size.height <= 667.0 {
//                self.guideScrollView.frame.size.height = self.guideScrollView.frame.size.height - 220.0
//                guideScrollView.frame.origin.y = 60.0
//            }
//            self.guideScrollView.frame.size.height = 550.0

//            self.appGuideView.frame.size.height = UIScreen.main.bounds.size.height
//
//            self.appGuideView.frame.size.width = UIScreen.main.bounds.size.width
//            self.guideScrollView.frame.size.width = UIScreen.main.bounds.size.width
            var originX = 0.0
            for i in 0..<totalImages {
                let imgView = UIImageView(frame: CGRect(x: originX, y: 0.0, width: guideScrollView.frame.size.width, height: guideScrollView.frame.size.height))
                imgView.contentMode = .scaleAspectFit
                imgView.backgroundColor = i == 2 || i == 3 ? UIColor(hexString: "1E1E1E") : .black
//                imgView.clipsToBounds = true
                imgView.image = UIImage(named: "tutor\(i+1)")
                guideScrollView.addSubview(imgView)
                originX += guideScrollView.frame.size.width
            }
            guideScrollView.contentSize = CGSize(width: guideScrollView.frame.size.width * CGFloat(totalImages), height: guideScrollView.frame.size.height)
            pageController.numberOfPages = totalImages
            pageController.addTarget(self, action: #selector(self.changeBanner(_:)), for: .valueChanged)
            self.showHideView(self.appGuideView, isHidden: false)
            AGLetsStart.isHidden = true
            return
        }
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: [
          AnalyticsParameterItemID: "id-AppStart",
          AnalyticsParameterItemName: "AppStart",
          AnalyticsParameterContentType: "cont",
        ])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in
            if !showTutorial && !UserDefaults.standard.bool(forKey: Constants.UserDefault.GuideCompleted) {
                var originX = 0.0
                for i in 0..<totalImages {
                    let imgView = UIImageView(frame: CGRect(x: originX, y: 0, width: guideScrollView.frame.size.width, height: guideScrollView.frame.size.height))
                    imgView.contentMode = .scaleAspectFit
                    imgView.backgroundColor = UIColor(hexString: "1E1E1E")
                    imgView.image = UIImage(named: "tutorial\(i+1)")
                    guideScrollView.addSubview(imgView)
                    originX += guideScrollView.frame.size.width
                }
                guideScrollView.contentSize = CGSize(width: guideScrollView.frame.size.width * CGFloat(totalImages), height: guideScrollView.frame.size.height)
                pageController.numberOfPages = totalImages
                pageController.addTarget(self, action: #selector(self.changeBanner(_:)), for: .valueChanged)
                self.showHideView(self.appGuideView, isHidden: false)
                AGLetsStart.isHidden = true
                return
            }
            moveToScreen()
        }
    }
    
    func isUpdateAvailable() throws -> Bool {
        guard let info = Bundle.main.infoDictionary,
//            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(identifier)") else {
            throw VersionError.invalidBundleInfo
        }
        let data = try Data(contentsOf: url)
        guard let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] else {
            throw VersionError.invalidResponse
        }
        if let result = (json["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String {
            return Double(version) != Constants.appVersion
        }
        throw VersionError.invalidResponse
    }
    
    func getCurrentVersion() throws -> Double {
        guard let info = Bundle.main.infoDictionary,
//            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(identifier)") else {
            throw VersionError.invalidBundleInfo
        }
        let data = try Data(contentsOf: url)
        guard let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] else {
            throw VersionError.invalidResponse
        }
        if let result = (json["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String, let versionNumebr = Double(version) {
            return versionNumebr
        }
        throw VersionError.invalidResponse
    }
    
    private func showHideView(_ viewd: UIView, isHidden: Bool) {
        UIView.transition(with: viewd, duration: 0.5, options: .transitionCrossDissolve, animations: {
            UIView.animate(withDuration: 0.25, animations: {
                viewd.isHidden = isHidden
            })
        }, completion: nil)
    }
    
    @objc func changeBanner(_ sender: UIPageControl) {
        let x = CGFloat(sender.currentPage) * guideScrollView.frame.size.width
        guideScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        
        self.AGLetsStart.isHidden = self.pageController.currentPage != totalImages - 1
        self.AGNextButton.isHidden = !self.AGLetsStart.isHidden
        self.AGskipButton.isHidden = !self.AGLetsStart.isHidden
    }
    
    @IBAction func tapOnAppGuide(_ sender: UIButton) {
        //1-Skip
        //2-Next
        //3-Lets Start
        if sender.tag == 2 {
            self.pageController.currentPage = self.pageController.currentPage + 1
            let xOrigin = Double(self.guideScrollView!.frame.size.width) * Double(self.pageController.currentPage)
            self.guideScrollView!.scrollRectToVisible(CGRect(x: xOrigin, y: 0.0, width: Double(self.guideScrollView!.frame.size.width), height: Double(self.guideScrollView!.frame.size.height)), animated: true)
            if self.pageController.currentPage == totalImages - 1 {
                self.AGLetsStart.isHidden = false
                self.AGNextButton.isHidden = !self.AGLetsStart.isHidden
                self.AGskipButton.isHidden = !self.AGLetsStart.isHidden
            }
        } else {
            self.appGuideView.isHidden = true
            if showTutorial {
                self.navigationController?.popViewController(animated: false)
            } else {
                UserDefaults.standard.set(sender.tag == 3, forKey: Constants.UserDefault.GuideCompleted)
                UserDefaults.standard.synchronize()
                self.moveToScreen()
            }
        }
    }
    
    private func moveToScreen() {
        do {
            if Constants.enableForceUpdate {
                let updateAvailable = try self.isUpdateAvailable()
                if updateAvailable {
                    self.splashImage.image = UIImage(named: "splash")
                    
                    // show alert
                    let alert = UIAlertController(title: "Update Available", message: "A new version of Tale'o'meter App is available. Please update to version 1.4.8 now.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { action in
                        UIApplication.shared.open(URL(string: "https://apps.apple.com/us/app/taleometer/id1621063908")!)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            exit(0)
                        }
                    }))
//                    alert.addAction(UIAlertAction(title: "Do it later", style: .destructive, handler: { [self] action in
//                        redirectToApp()
//                    }))
                    self.present(alert, animated: true)
                    return
                }
            }
            redirectedToScreen()
        } catch {
            redirectedToScreen()
        }
    }
    
    private func redirectedToScreen() {
        if isOnlyTrivia {
            if let profileData = Login.getProfileData() {
                if profileData.Is_login, !profileData.StoryBoardName.isBlank, !profileData.StoryBoardId.isBlank {
                    Core.push(self, storyboard: profileData.StoryBoardName, storyboardId: profileData.StoryBoardId)
                } else if profileData.Is_login {
                    if categorId != -2 {
                        if let myobject = UIStoryboard(name: Constants.Storyboard.trivia, bundle: nil).instantiateViewController(withIdentifier: "TRFeedViewController") as? TRFeedViewController {
                            myobject.categoryId = categorId
                            myobject.redirectToPostId = postId
                            self.navigationController?.pushViewController(myobject, animated: true)
                            return
                        }
                    }
                    Core.push(self, storyboard: Constants.Storyboard.trivia, storyboardId: "TriviaViewController", animated: false)
                } else {
                    Core.push(self, storyboard: Constants.Storyboard.auth, storyboardId: "LoginViewController", animated: false)
                }
            } else {
                Core.push(self, storyboard: Constants.Storyboard.auth, storyboardId: "LoginViewController", animated: false)
            }
        } else {
            
            if let profileData = Login.getProfileData(), profileData.Is_login, Core.GetAppVersion() == "1.4.7", !UserDefaults.standard.bool(forKey: "isTaleometer1.0First") {
                AuthClient.logout()
            }
            if Core.GetAppVersion() == "1.4.7" && !UserDefaults.standard.bool(forKey: "isTaleometer1.0First") {
                UserDefaults.standard.set(true, forKey: "isTaleometer1.0First")
            }
            if let profileData = Login.getProfileData() {
                if profileData.Is_login, !profileData.StoryBoardName.isBlank, !profileData.StoryBoardId.isBlank {
                    Core.push(self, storyboard: profileData.StoryBoardName, storyboardId: profileData.StoryBoardId, animated: false)
                    return
                }
            }
            if UserDefaults.standard.bool(forKey: Constants.UserDefault.IsLogin) && storyId != -1 {
                if let myobject = UIStoryboard(name: Constants.Storyboard.audio, bundle: nil).instantiateViewController(withIdentifier: "NowPlayViewController") as? NowPlayViewController {
                    myobject.storyIdis = storyId
                    self.navigationController?.pushViewController(myobject, animated: true)
                    return
                }
            }
            Core.push(self, storyboard: Constants.Storyboard.dashboard, storyboardId: "DashboardViewController", animated: false)
        }
    }
}

extension LaunchViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageController.currentPage = Int(pageNumber)
        
        self.AGLetsStart.isHidden = self.pageController.currentPage != totalImages - 1
        self.AGNextButton.isHidden = !self.AGLetsStart.isHidden
        self.AGskipButton.isHidden = !self.AGLetsStart.isHidden
    }
}
