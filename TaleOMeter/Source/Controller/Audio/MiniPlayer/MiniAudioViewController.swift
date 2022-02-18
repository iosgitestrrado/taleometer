//
//  MiniAudioViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit
import CoreMedia

class MiniAudioViewController: UIViewController {

    // MARK: - Weak Property -
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var fullViewButton: UIButton!
    @IBOutlet weak var songTitle: MarqueeLabel!
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if touch.view?.tag == 9995555 {
            let location = touch.location(in: touch.view)
            progressBar.progress = Float(location.x / progressBar.frame.size.width)
            if let player = AudioPlayManager.shared.playerAV, let secondDuration = player.currentItem?.duration.seconds {
                let total = Int(secondDuration * Double(location.x / progressBar.frame.size.width))
                let targetTime : CMTime = CMTimeMake(value: Int64(total), timescale: 1)
                player.seek(to: targetTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}
