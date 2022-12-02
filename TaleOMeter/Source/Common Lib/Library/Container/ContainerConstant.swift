//
//  ContainerConstant.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit
import Foundation

// MARK: - Container constanct class -
open class ContainerConstant {

    public static func addContainerTo(_ viewController: UIViewController, containerControllers: NSArray, menuIndicatorColor: UIColor, menuItemTitleColor: UIColor, menuItemSelectedTitleColor: UIColor, menuBackGroudColor: UIColor, font: UIFont, menuViewWidth: CGFloat) -> ContainerViewController {
        let contaninerVC = ContainerViewController(controllers: containerControllers, topBarHeight: 0.0, parentViewController: viewController)
        contaninerVC.menuItemFont = font
        contaninerVC.menuBackGroudColor = menuBackGroudColor
        contaninerVC.menuWidth = (menuViewWidth - 50.0) / CGFloat(containerControllers.count)
        contaninerVC.menuViewWidth = menuViewWidth
        
        if contaninerVC.menuWidth <= 80.0 {
            contaninerVC.menuWidth = 80.0
        }

        if let delegate = viewController as? ContainerVCDelegate {
            contaninerVC.delegate = delegate
        }
        contaninerVC.menuIndicatorColor = menuIndicatorColor
        contaninerVC.menuItemTitleColor = menuItemTitleColor
        contaninerVC.menuItemSelectedTitleColor = menuItemSelectedTitleColor
        contaninerVC.view.shadow = true

        viewController.view.subviews.forEach({ $0.removeFromSuperview() })
        viewController.view.addSubview(contaninerVC.view)
        return contaninerVC
    }
}
