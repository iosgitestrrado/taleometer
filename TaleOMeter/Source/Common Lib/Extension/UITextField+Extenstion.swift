//
//  UITextField+Extenstion.swift
//  TaleOMeter
//
//  Created by Durgesh on 15/03/22.
//

import UIKit

private var rightViews = NSMapTable<UITextField, UIView>(keyOptions: NSPointerFunctions.Options.weakMemory, valueOptions: NSPointerFunctions.Options.strongMemory)
private var errorViews = NSMapTable<UITextField, UIView>(keyOptions: NSPointerFunctions.Options.weakMemory, valueOptions: NSPointerFunctions.Options.strongMemory)

extension UITextField
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
    
    // Add/remove error message
    func setError(_ string: String? = nil, show: Bool = true) {
        // Get current window
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
        if let textContainer = window.viewWithTag(9998) {
            textContainer.removeFromSuperview()
        }
        if let rightView = rightView, rightView.tag != 999 {
            rightViews.setObject(rightView, forKey: self)
        }

        // Remove message
        guard string != nil else {
            if let rightView = rightViews.object(forKey: self) {
                self.rightView = rightView
                rightViews.removeObject(forKey: self)
            } else {
                self.rightView = nil
            }

            if let errorView = errorViews.object(forKey: self) {
                errorView.isHidden = true
                errorViews.removeObject(forKey: self)
            }

            return
        }

        // Create container
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.tag = 9998

        // Create triangle
        let triagle = TriangleTop()
        triagle.backgroundColor = .clear
        triagle.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(triagle)

        // Create red line
        let line = UIView()
        line.backgroundColor = .red
        line.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(line)

        // Create message
        let label = UILabel()
        label.text = "  \(string!)  "
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 15.0)
        label.backgroundColor = .black
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 250), for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)

        // Set constraints for triangle
        triagle.heightAnchor.constraint(equalToConstant: 10).isActive = true
        triagle.widthAnchor.constraint(equalToConstant: 15).isActive = true
        triagle.topAnchor.constraint(equalTo: container.topAnchor, constant: -10).isActive = true
        triagle.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15).isActive = true

        // Set constraints for line
        line.heightAnchor.constraint(equalToConstant: 3).isActive = true
        line.topAnchor.constraint(equalTo: triagle.bottomAnchor, constant: 0).isActive = true
        line.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0).isActive = true
        line.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0).isActive = true

        // Set constraints for label
        label.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0).isActive = true
        label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0).isActive = true
        label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0).isActive = true
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true

        if !show {
            container.isHidden = true
        }
        // superview!.superview!.addSubview(container)
        
        window.addSubview(container)

        // Set constraints for container
        container.widthAnchor.constraint(lessThanOrEqualTo: superview!.widthAnchor, multiplier: 2).isActive = true
        container.trailingAnchor.constraint(equalTo: superview!.trailingAnchor, constant: 0).isActive = true
        container.topAnchor.constraint(equalTo: superview!.bottomAnchor, constant: 0).isActive = true

        // Hide other error messages
        let enumerator = errorViews.objectEnumerator()
        while let view = enumerator!.nextObject() as! UIView? {
            view.isHidden = true
        }

        // Add right button to textField
        let errorButton = UIButton(type: .custom)
        errorButton.tag = 999
        errorButton.setImage(UIImage(named: "ic_error"), for: .normal)
        errorButton.frame = CGRect(x: 0, y: 0, width: frame.size.height, height: frame.size.height)
        errorButton.addTarget(self, action: #selector(errorAction), for: .touchUpInside)
        rightView = errorButton
        rightViewMode = .always

        // Save view with error message
        errorViews.setObject(container, forKey: self)
    }
    
    // Show error message
    @IBAction func errorAction(_ sender: Any) {
        let errorButton = sender as! UIButton
        let textField = errorButton.superview as! UITextField

        let errorView = errorViews.object(forKey: textField)
        if let errorView = errorView {
            errorView.isHidden.toggle()
        }

        let enumerator = errorViews.objectEnumerator()
        while let view = enumerator!.nextObject() as! UIView? {
            if view != errorView {
                view.isHidden = true
            }
        }
//            // Don't hide keyboard after click by icon
//            UIViewController.isCatchTappedAround = false
    }
}

class TriangleTop: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        context.beginPath()
        context.move(to: CGPoint(x: (rect.maxX / 2.0), y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: (rect.minX / 2.0), y: rect.maxY))
        context.closePath()

        context.setFillColor(UIColor.red.cgColor)
        context.fillPath()
    }
}


class Validator {
    static func showRequiredError(_ field: UITextField) {
        field.setError("Required", show: true)
    }
    
    static func showError(_ field: UITextField, message: String) {
        field.setError(message, show: true)
    }
    
    static func showRequiredErrorTextView(_ textView: UITextView) {
        textView.setError("Required", show: true)
    }
    
    static func showErrorTextView(_ textView: UITextView, message: String) {
        textView.setError(message, show: true)
    }
}


protocol BackSpaceDelegate {
    func deleteBackWord(textField: CustomTextField)
}

class CustomTextField: UITextField {
    var backSpaceDelegate: BackSpaceDelegate?
    override func deleteBackward() {
        super.deleteBackward()
        // called when textfield is empty. you can customize yourself.
        if text?.isEmpty ?? false {
             backSpaceDelegate?.deleteBackWord(textField: self)
        }
    }
}
