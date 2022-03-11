//
//  PreferenceViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 15/02/22.
//

import UIKit
import Magnetic
import SpriteKit
import SDWebImage

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
    fileprivate var magnetic: Magnetic {
        return magneticView.magnetic
    }
    fileprivate var timerg: Timer?
    fileprivate var timer = Timer()
    fileprivate var totalNodes = 0
    fileprivate var firstNode: Node?
    fileprivate var bubbles = [Preference]()
    fileprivate var selectedBubbles = [Int]()

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
        Core.showNavigationBar(cont: self, setNavigationBarHidden: true, isRightViewEnabled: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getBubbles()
    }
    
    // MARK: - Get bubbles from API's -
    private func getBubbles() {
        Core.ShowProgress(self, detailLbl: "")
        PreferenceClient.getUserBubbles { result in
            if let selected = result {
                selected.forEach { bubble in
                    self.selectedBubbles.append(bubble.Preference_bubble_id)
                }
            }
            PreferenceClient.getBubbles { [self] result in
                if let response = result, response.count > 0 {
                    totalNodes = 0
                    bubbles = response
                    timer = Timer(timeInterval: 0.5, target: self, selector: #selector(addNode), userInfo: nil, repeats: true)
                    RunLoop.main.add(timer, forMode: .default)
                    timer.fire()
                }
                Core.HideProgress(self)
            }
        }
    }
    
    @IBAction func tapOnSkipButton(_ sender: Any) {
        Core.ShowProgress(self, detailLbl: "")
        PreferenceClient.setUserBubbles(PreferenceRequest(preference_bubble_ids: selectedBubbles)) { status in
            Core.HideProgress(self)
            Login.removeStoryBoardData()
            Core.push(self, storyboard: Constants.Storyboard.dashboard, storyboardId: "DashboardViewController")
        }
    }
    
    @objc func addNode() {
        if totalNodes >= bubbles.count
        {
            timer.invalidate()
            return
        }
        //let name = UIImage.names.randomItem() //checkmark.seal.fill
        //let color = UIColor.colors.randomItem()
        
        let bubblePref = bubbles[totalNodes]
        
        let node = Node(text: "", image: bubblePref.Image, color: .white, radius: 10.0)
        node.originalTexture = SKTexture(image: bubblePref.Image)
        node.selectedTexture = SKTexture(image: Core.combineImages(bubblePref.Image, topImage: UIImage(named: "Default_sel_img")!))
        
        node.scaleToFitContent = true
        node.selectedColor = .clear
        node.selectedStrokeColor = .red
        node.tag = bubblePref.Id
        node.isSelected = selectedBubbles.contains(node.tag)
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
        selectedBubbles.append(node.tag)
        //print("didSelect -> \(node)")
    }
    
    func magnetic(_ magnetic: Magnetic, didDeselect node: Node) {
        if let indx = selectedBubbles.firstIndex(of: node.tag) {
            selectedBubbles.remove(at: indx)
        }
        //print("didDeselect -> \(node)")
    }
    
    func magnetic(_ magnetic: Magnetic, didRemove node: Node) {
        //print("didRemove -> \(node)")
    }
    
}
