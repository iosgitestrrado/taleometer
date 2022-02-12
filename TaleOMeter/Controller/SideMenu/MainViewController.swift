//
//  MainViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 12/02/22.
//

import UIKit
import LGSideMenuController

class MainViewController: LGSideMenuController {

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: menuIconImage, style: .plain, target: self, action: #selector(showRightViewAction(sender:)))
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        struct Counter { static var count = 0 }
        Counter.count += 1
        
        let statusBarHeight = getStatusBarFrame().height
        rightView!.frame = CGRect(x: 0.0, y: statusBarHeight, width: rightView!.bounds.width, height: view.bounds.height - statusBarHeight)
    }

    // MARK: - Other -
    @objc
    func showRightViewAction(sender: AnyObject?) {
        toggleRightView(animated: true)
    }
    
    // MARK: - Logging -

    deinit {
        struct Counter { static var count = 0 }
        Counter.count += 1
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        struct Counter { static var count = 0 }
        Counter.count += 1
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        struct Counter { static var count = 0 }
        Counter.count += 1
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        struct Counter { static var count = 0 }
        Counter.count += 1
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        struct Counter { static var count = 0 }
        Counter.count += 1
    }

    override func rootViewLayoutSubviews() {
        super.rootViewLayoutSubviews()
        struct Counter { static var count = 0 }
        Counter.count += 1
    }

    override func leftViewLayoutSubviews() {
        super.leftViewLayoutSubviews()
        struct Counter { static var count = 0 }
        Counter.count += 1
    }

    override func rightViewLayoutSubviews() {
        super.rightViewLayoutSubviews()
        struct Counter { static var count = 0 }
        Counter.count += 1
    }
}

