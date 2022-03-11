//
//  Helper.swift
//  TaleOMeter
//
//  Created by Durgesh on 12/02/22.
//

import Foundation
import UIKit

//Default color: 25253C 37,37,60

let remoteCommandName = NSNotification.Name(rawValue: "RemoteCommandHandler")

let supportedAudioExtenstion = ["mp3", "mp4", "m4a", "wav", "aac", "adts", "ac3", "aif", "aiff", "aifc", "caf", "snd", "au", "sd2"]
let defaultImage = UIImage(named: "logo")!
let isOnlyTrivia = false

// MARK: - Side menubar properties -
let menuIconImage: UIImage = {
    let size = CGSize(width: 24.0, height: 16.0)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
        let ctx = context.cgContext
        let lineHeight: CGFloat = 2.0

        ctx.setFillColor(UIColor.black.cgColor)
        ctx.setStrokeColor(UIColor.black.cgColor)
        ctx.setLineWidth(lineHeight)
        ctx.setLineCap(.round)

        ctx.beginPath()

        ctx.move(to: CGPoint(x: lineHeight, y: lineHeight / 2.0))
        ctx.addLine(to: CGPoint(x: size.width - lineHeight, y: lineHeight / 2.0))

        ctx.move(to: CGPoint(x: lineHeight, y: size.height / 2.0))
        ctx.addLine(to: CGPoint(x: size.width - lineHeight, y: size.height / 2.0))

        ctx.move(to: CGPoint(x: lineHeight, y: size.height - lineHeight / 2.0))
        ctx.addLine(to: CGPoint(x: size.width - lineHeight, y: size.height - lineHeight / 2.0))

        ctx.strokePath()
    }
}()


func isLightTheme() -> Bool {
    if #available(iOS 13.0, *) {
        let currentStyle = UITraitCollection.current.userInterfaceStyle
        return currentStyle == .light || currentStyle == .unspecified
    }
    else {
        return true
    }
}

func getKeyWindow() -> UIWindow? {
    if #available(iOS 13.0, *) {
        return (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first
    } else {
        return UIApplication.shared.keyWindow
    }
}

func getStatusBarFrame() -> CGRect {
    if #available(iOS 13.0, *) {
        return getKeyWindow()?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
    } else {
        return UIApplication.shared.statusBarFrame
    }
}


