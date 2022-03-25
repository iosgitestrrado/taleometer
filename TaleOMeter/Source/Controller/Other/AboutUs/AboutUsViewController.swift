//
//  AboutUsViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit

class AboutUsViewController: UIViewController {

    // MARK: - Weak Property -
    @IBOutlet weak var textView: UITextView!
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sideMenuController!.toggleRightView(animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        OtherClient.getStaticContent(true) { response in
            if let data = response, !data.Value.isBlank {
                self.textView.attributedText = data.Value.htmlToAttributedString
                self.textView.textColor = .white
            }
            Core.HideProgress(self)
        }
    }
    
    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        self.sideMenuController!.toggleRightView(animated: true)
    }
}
