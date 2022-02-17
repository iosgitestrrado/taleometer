//
//  AudioContainerViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit

class AudioContainerViewController: UIViewController {

    // MARK: - Weak Property -
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var fullViewButton: UIButton!
    @IBOutlet weak var songTitle: MarqueeLabel!
    @IBOutlet weak var songImage: UIImageView!
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
