//
//  SettingViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit

class SettingViewController: UIViewController {

    // MARK: - Weak Property -
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var autoPlaySwitch: UISwitch!
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        notificationSwitch.isOn = UserDefaults.standard.bool(forKey: "NotificationEnable")
        autoPlaySwitch.isOn = UserDefaults.standard.bool(forKey: "AutoplayEnable")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true)
    }
    
    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        self.sideMenuController!.toggleRightView(animated: true)
    }
    
    @IBAction func changeNotification(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "NotificationEnable")
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func changeAutoplay(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "AutoplayEnable")
        UserDefaults.standard.synchronize()
    }
}
