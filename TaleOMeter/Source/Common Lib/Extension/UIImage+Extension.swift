//
//  UIImage+Extension.swift
//  TaleOMeter
//
//  Created by Durgesh on 15/02/22.
//

import UIKit

extension UIImage {
    static let names: [String] = ["argentina", "bolivia", "brazil", "chile", "costa rica", "cuba", "dominican republic", "ecuador", "el salvador", "haiti", "honduras", "mexico", "nicaragua", "panama", "paraguay", "peru", "venezuela"]
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!

        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!

        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)

        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    
    func makeFixOrientation() -> UIImage {
            if self.imageOrientation == UIImage.Orientation.up {
                return self
            }

            UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
            self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
            let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()

            return normalizedImage;
        }
}
