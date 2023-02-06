//
//  UISegmentController+Extension.swift
//  TaleOMeter
//
//  Created by Durgesh on 09/12/22.
//

import UIKit

class CustomSegmentedControl: UISegmentedControl {
    private let segmentInset: CGFloat = 8      //your inset amount
    private let segmentImage: UIImage? = UIImage(color: UIColor(displayP3Red: 74.0 / 255.0, green: 73.0 / 255.00, blue: 113.0 / 255.0, alpha: 1.0))    //your color

    override func layoutSubviews(){
        super.layoutSubviews()

        //background
        layer.cornerRadius = bounds.height/2
        //foreground
        let foregroundIndex = numberOfSegments
        if subviews.indices.contains(foregroundIndex), let foregroundImageView = subviews[foregroundIndex] as? UIImageView
        {
            foregroundImageView.bounds = foregroundImageView.bounds.insetBy(dx: segmentInset, dy: segmentInset)
            foregroundImageView.image = segmentImage    //substitute with our own colored image
            foregroundImageView.layer.removeAnimation(forKey: "SelectionBounds")    //this removes the weird scaling animation!
            foregroundImageView.layer.masksToBounds = true
            foregroundImageView.layer.cornerRadius = foregroundImageView.bounds.height/2
        }
    }
}
