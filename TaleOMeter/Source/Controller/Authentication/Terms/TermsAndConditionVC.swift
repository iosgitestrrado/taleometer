//
//  TermsAndConditionVC.swift
//  TaleOMeter
//
//  Created by Durgesh on 15/02/22.
//

import UIKit

class TermsAndConditionVC: UIViewController {
    
    // MARK: - Weak Properties -
    @IBOutlet weak var textView: UITextView!
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: false, backImage: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        OtherClient.getStaticContent(false) { response in
            if let data = response, !data.Value.isBlank {
                self.textView.attributedText = data.Value.htmlToAttributedString
                self.textView.textColor = UIColor(displayP3Red: 84.0 / 255.0, green: 85.0 / 255.0, blue: 135.0 / 255.0, alpha: 1.0) //84,85,135
            }
            Core.HideProgress(self)
        }
    }
}
