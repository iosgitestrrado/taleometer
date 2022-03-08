//
//  UiTextView+Extension.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

import UIKit

extension UITextView
{
    func addInputAccessoryView(_ title: String, target: Any, selector: Selector, tag: Int = 0) {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44.0))
        toolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let btn = UIBarButtonItem(title: title, style: .done, target: target, action: selector)
        btn.tag = tag
        let items: [UIBarButtonItem] = [flexSpace, btn]
        toolbar.items = items
        self.inputAccessoryView = toolbar
    }
}


