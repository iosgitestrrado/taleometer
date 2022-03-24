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
        notificationSwitch.isOn = true
        autoPlaySwitch.isOn = UserDefaults.standard.bool(forKey: "AutoplayEnable")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let profileData = Login.getProfileData() {
            notificationSwitch.isOn = profileData.Push_notify
            autoPlaySwitch.isOn = profileData.Autoplay.lowercased().contains("enable")
        }
    }
    
    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        self.sideMenuController!.toggleRightView(animated: true)
    }
    
    @IBAction func changeNotification(_ sender: UISwitch) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        OtherClient.setNotificationSetting(NotificationSetRequest(value: sender.isOn ? 1 : 0)) { status in
            Core.HideProgress(self)
        }
    }
    
    @IBAction func changeAutoplay(_ sender: UISwitch) {
        Core.ShowProgress(self, detailLbl: "")
        OtherClient.setAutoPlaySetting(AutoplaySetRequest(value: sender.isOn ? "Enable" : "Disable")) { status in
            if let st = status, st {
                UserDefaults.standard.set(sender.isOn, forKey: "AutoplayEnable")
                UserDefaults.standard.synchronize()
            }
            Core.HideProgress(self)
        }
    }
}
