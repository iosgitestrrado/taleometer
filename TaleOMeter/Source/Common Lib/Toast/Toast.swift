//
//  Toast.swift
//  TaleOMeter
//
//  Created by Durgesh on 15/03/22.
//

import UIKit

class Toast: NSObject {
    static func show(_ message: String = "") {
        DispatchQueue.main.async {
            // Get current window
            guard let superview = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
            
            // Make toast constraint
            let toastContainer = UIView(frame: CGRect())
            toastContainer.backgroundColor = .gray//UIColor.black.withAlphaComponent(0.6)
            toastContainer.alpha = 0.0
            toastContainer.layer.cornerRadius = 20;
            toastContainer.clipsToBounds  =  true

            // Set toast label
            let toastLabel = UILabel(frame: CGRect())
            toastLabel.textColor = UIColor.white
            toastLabel.textAlignment = .center
            toastLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
            // Message black to set internet message
            toastLabel.text = message.isBlank ? "Please check your internet connection and try again.!!" : message
            toastLabel.clipsToBounds  =  true
            toastLabel.numberOfLines = 0
            
            // Add Toast lable to container
            toastContainer.addSubview(toastLabel)
            
            // Add container to view
            superview.addSubview(toastContainer)

            // set constraint
            toastLabel.translatesAutoresizingMaskIntoConstraints = false
            toastContainer.translatesAutoresizingMaskIntoConstraints = false

            // Set label constraint
            let a1 = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 10)
            let a2 = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -10)
            let a3 = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -10)
            let a4 = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 10)
            toastContainer.addConstraints([a1, a2, a3, a4])

            // Set toast container constraint
            let c1 = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 65)
            let c2 = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: -65)
            let c3 = NSLayoutConstraint(item: toastContainer, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1, constant: -75)
            superview.addConstraints([c1, c2, c3])

            // Show toast with animation
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
                toastContainer.alpha = 1.0
            }, completion: { _ in
                UIView.animate(withDuration: 0.5, delay: 1.0, options: .curveEaseOut, animations: {
                    toastContainer.alpha = 0.0
                }, completion: {_ in
                    toastContainer.removeFromSuperview()
                })
            })
        }
    }
}
