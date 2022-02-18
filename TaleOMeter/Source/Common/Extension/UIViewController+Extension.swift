//
//  UIViewController+Extension.swift
//  TaleOMeter
//
//  Created by Durgesh on 14/02/22.
//

import Foundation
import UIKit

extension UIViewController {
    
    func hideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
