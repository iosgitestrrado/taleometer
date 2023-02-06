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
    
    @IBInspectable var shadowColor: UIColor {
        get {
            return UIColor.white
        }
        set {
            self.layer.shadowColor = newValue.cgColor
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            if !self.shadow {
                self.layer.masksToBounds = true
            }
        }
    }

    func addShadow(shadowOffset: CGSize = CGSize(width: 0.0, height: 2.0),
                   shadowOpacity: Float = 1.0,
                   shadowRadius: CGFloat = 5.0) {
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.masksToBounds = false
    }

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
