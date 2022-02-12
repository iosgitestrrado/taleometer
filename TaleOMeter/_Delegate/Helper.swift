//
//  Helper.swift
//  LGSideMenuControllerDemo
//

import Foundation
import UIKit

//Default color: 25253C 37,37,60

//Storybaord name
struct Storyboard {
    static let dashboard = "Main"
    static let sideMenu = "SideMenu"
    static let launch = "LaunchScreen"
}

struct SroryboardId {
    static let main = "NavigationController"
}

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
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
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

extension UIView {
    class func fromNib() -> Self {
        return Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)!.first as! Self
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexint = Int(Self.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    static private func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        let scanner: Scanner = Scanner(string: hexStr)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }
}

enum SideViewCellItem: Equatable {
    case profile
    case shareStory
    case history
    case preference
    case aboutUs
    case feedback
    case pushVC(title: String)

    var description: String {
        switch self {
        case .profile:
            return "My Account"
        case .shareStory:
            return "Share your Story"
        case .history:
            return "History"
        case .preference:
            return "Preference"
        case .aboutUs:
            return "About us"
        case .feedback:
            return "Feedback"
        case let .pushVC(title):
            return title
        }
    }
}
