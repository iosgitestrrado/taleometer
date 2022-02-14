//
//  RegisterViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 14/02/22.
//


import UIKit

class RegisterViewController: UIViewController {
    
    // MARK: - Storyboard Outlet / Connection -
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    
    // MARK: - Lifecycle -
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHideNotification), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboard()
        //self.navigationItem.hidesBackButton = true
        self.nameTextField.becomeFirstResponder()
    }
    
    @objc func keyboardWillShowNotification (notification: Notification) {
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue, self.view.frame.origin.y == 0.0 {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                let height = frame.cgRectValue.height
                self.view.frame.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height - height)
                        self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc func keyboardDidHideNotification (notification: Notification) {
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue, self.view.frame.origin.y != 0.0 {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                let height = frame.cgRectValue.height
                self.view.frame.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height + height)
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        }
    }
    
    @IBAction func tapOnSubmit(_ sender: Any) {
    }
}
