//
//  NoInternetViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 23/03/22.
//

import UIKit

// MARK: - Protocol used for sending data back -
protocol NoInternetDelegate: AnyObject {
    func connectedToNetwork(_ methodName: String)
}

class NoInternetViewController: UIViewController {

    // Making this a weak variable, so that it won't create a strong reference cycle
    weak var delegate: NoInternetDelegate? = nil
    var methodName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: true, isRightViewEnabled: false)
    }
    
    //
    @IBAction func tapOnConfirm(_ sender: Any) {
        if !Reachability.isConnectedToNetwork() {
            Toast.show()
            return
        }
        if let del = delegate, !methodName.isBlank {
            del.connectedToNetwork(methodName)
        }
        self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
