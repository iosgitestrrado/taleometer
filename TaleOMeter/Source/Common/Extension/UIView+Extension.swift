//
//  UIView+Extension.swift
//  TaleOMeter
//
//  Created by Durgesh on 15/02/22.
//

import UIKit

extension UIView {
    
    class func fromNib() -> Self {
        return Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)!.first as! Self
    }
    
    func StartAnimation(duration : Double, orginy: Double) {
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseIn]) {
            self.center.y = orginy
            self.layoutIfNeeded()
        } completion: { isDone in
            
        }
        self.isHidden = false
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            //            if newValue > 0.0 {
            //                self.layer.cornerRadius = (self.frame.size.height / 2.0) - 2.0
            //            } else {
            self.layer.cornerRadius = newValue
            //            }
            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
    }

    func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 1.0, height: 1.0),
                   shadowOpacity: Float = 0.2,
                   shadowRadius: CGFloat = 3.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
