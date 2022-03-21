//
//  UILabel+Extension.swift
//  TaleOMeter
//
//  Created by Durgesh on 22/02/22.
//

import UIKit

extension UILabel
{
    func addUnderline() {
       let spacing = 2 // will be added as negative bottom margin for more spacing between label and line
       let line = UIView()
       line.translatesAutoresizingMaskIntoConstraints = false
       line.backgroundColor = self.textColor
        self.addSubview(line)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[line]|", metrics: nil, views: ["line":line]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[line(1)]-(\(-spacing))-|", metrics: nil, views: ["line":line]))
    }
    
//    @IBInspectable var addUnderlineS: NSAttributedString {
//        get {
//
//        }
//        set {
//            self.attributedText = newValue
//        }
//    }
}
