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
    private let messageString = "Describe your feedback"
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboard()
        self.textView.addInputAccessoryView("Done", target: self, selector: #selector(self.doneToolbar(_:)))
        
        self.textView.text = messageString
        self.textView.textColor = .darkGray
        
        self.textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            self.sideMenuController!.toggleRightView(animated: false)
        }
    }
    
    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        self.sideMenuController!.toggleRightView(animated: true)
    }
    
    // MARK: - Side Menu button action -
    @IBAction func tapOnSubmit(_ sender: Any) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        if textView.text == messageString || textView.text.isBlank {
            Toast.show(messageString)
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        OtherClient.submitFeedback(FeedbackRequest(content: textView.text!)) { status in
            Core.HideProgress(self)
            if let st = status, st {
                PromptVManager.present(self, verifyTitle: "Thank You", verifyMessage: "For Your Valuable Feedback", verifyImage: UIImage(named: "thank"), isUserStory: true)
            }
        }
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
    @objc private func keyboardWillHideNotification (notification: Notification) {
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
