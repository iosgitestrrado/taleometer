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
}
