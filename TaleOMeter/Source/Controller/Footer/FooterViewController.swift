//
//  FooterViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 15/02/22.
//

import UIKit

class FooterViewController: UIViewController {
    
    // MARK: - Storyboard outlet -
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var favButton: UIButton!
    
    // MARK: - Public Properties -
    public var parentController: UIViewController?
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Core.showNavigationBar(cont: self, setNavigationBarHidden: true, isRightViewEnabled: false)
    }
}
