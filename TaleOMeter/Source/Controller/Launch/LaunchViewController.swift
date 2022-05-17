//
//  LaunchViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 12/02/22.
//

import UIKit
import SwiftGifOrigin

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
    
    private var totalImages = 5
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.splashImage.image = UIImage.gif(name: "splash_anim_new")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [self] in
            if !UserDefaults.standard.bool(forKey: Constants.UserDefault.GuideCompleted) {
                var originX = 0.0
                for i in 0..<totalImages {
                    let imgView = UIImageView(frame: CGRect(x: originX, y: 0, width: guideScrollView.frame.size.width, height: guideScrollView.frame.size.height))
                    imgView.contentMode = .scaleToFill
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
            moveToScreen()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: true, isRightViewEnabled: false)
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
            UserDefaults.standard.set(sender.tag == 3, forKey: Constants.UserDefault.GuideCompleted)
            UserDefaults.standard.synchronize()
            self.appGuideView.isHidden = true
            self.moveToScreen()
        }
    }
    
    private func moveToScreen() {
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
