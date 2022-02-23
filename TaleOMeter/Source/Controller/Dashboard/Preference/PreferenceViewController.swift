//
//  PreferenceViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 15/02/22.
//

import UIKit
import Magnetic
import SpriteKit

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
    
    // MARK: - Private Properties -
    private var magnetic: Magnetic {
        return magneticView.magnetic
    }
    private var timerg: Timer?
    private var timer = Timer()
    private var totalNodes = 0
    private var firstNode: Node?

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.timerg = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.runTimedCode), userInfo: nil, repeats: true)
    }
    
    @objc func runTimedCode() {
        if let nodd = firstNode, nodd.position.y + nodd.frame.size.height > UIScreen.main.bounds.size.height {
            timerg?.invalidate()
            skipButton.isHidden = false
        }
//        for node in magnetic.children {
//            if node.position.y + node.frame.size.height > UIScreen.main.bounds.size.height {
//                timerg?.invalidate()
//                skipButton.isHidden = false
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
        Core.showNavigationBar(cont: self, setNavigationBarHidden: true, isRightViewEnabled: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        for idx in 0..<50 {
//            self.addNodes(idx)
//        }
        timer = Timer(timeInterval: 0.5, target: self, selector: #selector(PreferenceViewController.addNodes(_:)), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .default)
        timer.fire()
    }
    
    @IBAction func tapOnSkipButton(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "isRegistered")
        UserDefaults.standard.synchronize()
        Core.push(self, storyboard: Storyboard.dashboard, storyboardId: "DashboardViewController")
        //self.performSegue(withIdentifier: "dashboard", sender: sender)
    }
    
    @IBAction func addNodes(_ sender: UIButton) {
        if totalNodes > 100
        {
            timer.invalidate()
            return
        }
        //let name = UIImage.names.randomItem() //checkmark.seal.fill
        let color = UIColor.colors.randomItem()
        let node = Node(text: "", image: UIImage(named: "Default_img"), color: color, radius: 10.0)
        node.originalTexture = SKTexture(image: UIImage(named: "Default_img")!)
        node.selectedTexture = SKTexture(image: UIImage(named: "Default_sel_img")!)
        node.scaleToFitContent = true
        node.selectedColor = .clear
        node.selectedStrokeColor = .red
        node.speed = 0.1
        if totalNodes == 0 {
            firstNode = node
        }
        magnetic.addChild(node)
        node.position = CGPoint(x: Int.random(in: 0..<Int(UIScreen.main.bounds.width)), y: -50)
        totalNodes += 1
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
