//
//  PreferenceViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 15/02/22.
//

import UIKit
import Magnetic

class PreferenceViewController: UIViewController {

    // MARK: - Storyboard outlet -
    @IBOutlet weak var magneticView: MagneticView! {
        didSet {
            magnetic.magneticDelegate = self
            magnetic.totalNodes = 100
            magnetic.removeNodeOnLongPress = false
            #if DEBUG
            magneticView.showsFPS = false
            magneticView.showsDrawCount = false
            magneticView.showsQuadCount = false
            magneticView.showsPhysics = true
            #endif
        }
    }
    @IBOutlet weak var skipButton: UIButton!
    
    var magnetic: Magnetic {
        return magneticView.magnetic
    }
    
    var firstNode: Node?
    var timerg: Timer?
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        timerg = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
    }
    
    @objc func runTimedCode() {
        for node in magnetic.children {
            if node.position.y + node.frame.size.height > UIScreen.main.bounds.size.height {
                timerg?.invalidate()
                skipButton.isHidden = false
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
        Core.showNavigationBar(cont: self, setNavigationBarHidden: true, isRightViewEnabled: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for idx in 0..<50 {
            self.addNodes(idx)
        }
    }
    
    @IBAction func tapOnSkipButton(_ sender: Any) {
        self.performSegue(withIdentifier: "dashboard", sender: sender)
    }
    
    @IBAction func addNodes(_ sender: Int) {
        let name = UIImage.names.randomItem()
        let color = UIColor.colors.randomItem()
        let node = Node(text: name.capitalized, image: UIImage(named: name), color: color, radius: 0)
        node.scaleToFitContent = true
        node.selectedColor = UIColor.colors.randomItem()
        node.speed = 0.1
        node.inputView?.tag = sender
        if sender == 0 {
            firstNode = node
        }
        magnetic.addChild(node)
        node.position = CGPoint(x: Int.random(in: 0..<Int(UIScreen.main.bounds.width)), y: 0)
    }
}

// MARK: - MagneticDelegate
extension PreferenceViewController: MagneticDelegate {
    
    func magnetic(_ magnetic: Magnetic, didSelect node: Node) {
        print("didSelect -> \(node)")
    }
    
    func magnetic(_ magnetic: Magnetic, didDeselect node: Node) {
        print("didDeselect -> \(node)")
    }
    
    func magnetic(_ magnetic: Magnetic, didRemove node: Node) {
        print("didRemove -> \(node)")
    }
    
}
