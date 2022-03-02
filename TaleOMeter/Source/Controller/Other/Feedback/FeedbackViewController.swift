//
//  FeedbackViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit

class FeedbackViewController: UIViewController {

    // MARK: - Weak Property -
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - Private Property -
    private let messageString = "Describe you feedback"
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboard()
        let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40.0))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneToolbar(_:)))
        let items1: [UIBarButtonItem] = [flexSpace, done]
        doneToolbar.items = items1
        self.textView.inputAccessoryView = doneToolbar
        
        self.textView.text = messageString
        self.textView.textColor = .darkGray
        
        self.textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHideNotification), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        self.sideMenuController!.toggleRightView(animated: true)
    }
    
    // MARK: - Side Menu button action -
    @IBAction func tapOnSubmit(_ sender: Any) {
        if textView.text == messageString || textView.text.isBlank {
            Snackbar.showAlertMessage(messageString)
            return
        }
        PromptVManager.present(self, isAudioView: false, verifyTitle: "Thank You", verifyMessage: "For Your Valuable Feedback", imageName: "thank")
    }
    
    // MARK: - Click on done button of keyborad toolbar
    @objc private func doneToolbar(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
    
    // MARK: Keyboard will show
    @objc private func keyboardWillShowNotification (notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue  {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.bottomConstraint.constant = keyboardHeight
        }
    }
    
    // MARK: Keyboard will Hide
    @objc private func keyboardDidHideNotification (notification: Notification) {
        self.bottomConstraint.constant = 0
    }
}

// MARK: - UITextViewDelegate -
extension FeedbackViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .darkGray {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)

        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {

            textView.text = messageString
            textView.textColor = .darkGray

            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }

        // Else if the text view's placeholder is showing and the
        // length of the replacement string is greater than 0, set
        // the text color to white then set its text to the
        // replacement string
         else if textView.textColor == .darkGray && !text.isEmpty {
            textView.textColor = UIColor.white
            textView.text = text
        }

        // For every other case, the text should change with the usual
        // behavior...
        else {
            return true
        }

        // ...otherwise return false since the updates have already
        // been made
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == .darkGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = messageString
            textView.textColor = .darkGray
        }
    }
}

// MARK: - PromptViewDelegate -
extension FeedbackViewController: PromptViewDelegate {
    func didActionOnPromptButton(_ tag: Int) {
        //back to profile screen
        self.navigationController?.popViewController(animated: true)
    }
}
