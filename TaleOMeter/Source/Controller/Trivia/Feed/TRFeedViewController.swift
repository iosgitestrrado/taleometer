//
//  TRFeedViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 03/03/22.
//

import UIKit

class TRFeedViewController: UIViewController {
    
    // MARK: - Weak Properties -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tblBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true, titleInLeft: false)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHideNotification), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        self.sideMenuController!.toggleRightView(animated: true)
    }
    
    // MARK: Keyboard will show
    @objc private func keyboardWillShowNotification (notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue  {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.tblBottomConstraint.constant = keyboardHeight
        }
    }
    
    // MARK: Keyboard will Hide
    @objc private func keyboardDidHideNotification (notification: Notification) {
        self.tblBottomConstraint.constant = 0
    }
}

// MARK: - UITableViewDataSource -
extension TRFeedViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as? QuestionCellView else { return UITableViewCell() }
//        cell.configureCell(questionArray[indexPath.row].question, value: questionArray[indexPath.row].value, coverImage: questionArray[indexPath.row].image, videoUrl: questionArray[indexPath.row].videoUrl, controller: self, row: indexPath.row, isLastrow: questionArray.count - 1 == indexPath.row)
//        if let btn = cell.submitButton {
//            btn.tag = indexPath.row
//            btn.addTarget(self, action: #selector(tapOnSubmit(_:)), for: .touchUpInside)
//        }
        return cell
    }
}

// MARK: - UITableViewDelegate -
extension TRFeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 286
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) as? QuestionCellView else {
//            return
//        }
//        if !questionArray[indexPath.row].videoUrl.isBlank {
//            playVideo(indexPath.row)
//        }
    }
}

// MARK: - UITextFieldDelegate -
extension TRFeedViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let indexPath = IndexPath(row: textField.tag, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //let nextCellData = questionArray[textField.tag + 1]
        if textField.returnKeyType == .next {
            let indexPath = IndexPath(row: textField.tag + 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            if let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as? QuestionCellView, let textField = cell.answerText {
                tableView.reloadRows(at: [indexPath], with: .none)
                textField.becomeFirstResponder()
            }
        } else {
            self.view.endEditing(true)
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.questionArray[textField.tag].value = textField.text!
    }
}
