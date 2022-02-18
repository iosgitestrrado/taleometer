//
//  Helper.swift
//  LGSideMenuControllerDemo
//

import Foundation
import UIKit

//Default color: 25253C 37,37,60

//Storybaord name struct
struct Storyboard {
    static let dashboard = "Main"
    static let sideMenu = "SideMenu"
    static let launch = "LaunchScreen"
    static let auth = "Auth"
    static let audio = "Audio"
}

//Storybaord id struct
struct SroryboardId {
    static let main = "NavigationController"
}

//Flag for login
public var isLogIn = false

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
