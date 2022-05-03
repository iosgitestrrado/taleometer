//
//  UserStoryViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit

class UserStoryViewController: UIViewController {

    // MARK: - Weak Property -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tblBottomConstraint: NSLayoutConstraint!

    // MARK: - Privare Property -
    
    // MARK: - create property for story data
    private struct storyModel {
        var value = String()
        var textField: UITextField?
        var textView: UITextView?
        var id = String()
        var celldata = [UserStoryCellItem]()
    }
    private var storyDataList = [storyModel]()
    
    // MARK: - Radio button
    private var optionButton1 = UIButton()
    private var optionButton2 = UIButton()
        
    private let tamilTermsString = "தயவுசெய்து எங்களுடையது படியுங்கள் விதிமுறைகள் மற்றும் நிபந்தனைகள்"

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setStoryData()
        self.hideKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
        
    // MARK: - Add total cells in property
    private func setStoryData() {
        storyDataList.append(storyModel(value: "", id: UserStoryCellItem.name.cellIdentifier, celldata: [.name]))
        storyDataList.append(storyModel(value: "", id: UserStoryCellItem.storyAbout.cellIdentifier, celldata: [.storyAbout]))
        storyDataList.append(storyModel(value: "", id: UserStoryCellItem.lifeMoment.cellIdentifier, celldata: [.lifeMoment]))
        storyDataList.append(storyModel(value: "", id: UserStoryCellItem.sharePeople.cellIdentifier, celldata: [.sharePeople]))
        storyDataList.append(storyModel(value: "", id: UserStoryCellItem.incident.cellIdentifier, celldata: [.incident]))
        storyDataList.append(storyModel(value: "", id: UserStoryCellItem.anythingElse.cellIdentifier, celldata: [.anythingElse]))
        storyDataList.append(storyModel(value: "", id: UserStoryCellItem.terms.cellIdentifier, celldata: [.terms]))
        storyDataList.append(storyModel(value: "", id: UserStoryCellItem.submitButton.cellIdentifier, celldata: [.submitButton]))
    }
    
    // MARK: - Logic for click on radio button
    private func setOptionSelection(_ isOption1Selected: Bool){
        self.optionButton1.isSelected = isOption1Selected
        self.optionButton2.isSelected = !isOption1Selected
        
        var mySelfStr = "MySelf"
        var someoneStr = "Someone Else"
        if self.title != "English" {
            mySelfStr = "நானே"
            someoneStr = "வேறு யாரோ"
        }
        if isOption1Selected {
            self.storyDataList[1].value = mySelfStr
        } else {
            self.storyDataList[1].value = someoneStr
        }
    }
    
    // MARK: - Click on done button of keyborad toolbar
    @objc private func doneToolbar(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
    
    // MARK: - Click on next button of keyboard toolbar
    @objc private func nextToolbar(_ sender: UIBarButtonItem) {
        let nextCellData = storyDataList[sender.tag + 1]
        let indexPath = IndexPath(row: 0, section: sender.tag + 1)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            if let cell = tableView.dequeueReusableCell(withIdentifier: nextCellData.id, for: indexPath) as? UserStoryCell, let textField = cell.textField {
                tableView.reloadRows(at: [indexPath], with: .none)
                textField.becomeFirstResponder()
            }
        }
    }
    
    // MARK: Table view all button included submit terms and condition additional radio button
    @objc private func tapOnButton1(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            setOptionSelection(true)
            break
        case 6:
            Core.push(self, storyboard: Constants.Storyboard.auth, storyboardId: "TermsAndConditionVC")
            break
        default:
            for i in 0..<storyDataList.count {
                let story = storyDataList[i]
                if story.value.isBlank && story.id != UserStoryCellItem.submitButton.cellIdentifier && story.id != UserStoryCellItem.terms.cellIdentifier {
                    if let text = story.textView {
                        Validator.showRequiredErrorTextView(text)
                        tableView.scrollToRow(at: IndexPath(row: 0, section: i), at: .top, animated: true)
                        return
                    }
                    if let text = story.textField {
                        Validator.showRequiredError(text)
                        tableView.scrollToRow(at: IndexPath(row: 0, section: i), at: .top, animated: true)
                        return
                    }
                    Toast.show(story.celldata[0].errorMessge)
                    tableView.scrollToRow(at: IndexPath(row: 0, section: i), at: .top, animated: true)
                    return
                }
            }
            PromptVManager.present(self, verifyTitle: "Thank You", verifyMessage: "For Your Valuable Contribution", verifyImage: UIImage(named: "thank")!, isUserStory: true)
            //print(storyDataList)
            break
        }
    }
    
    // MARK: Table view radio button
    @objc private func tapOnButton2(_ sender: UIButton) {
        if sender.tag == 1 {
            setOptionSelection(false)
        }
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
    @objc private func keyboardWillHideNotification (notification: Notification) {
        self.tblBottomConstraint.constant = 0
    }
}

// MARK: - UITableViewDataSource -
extension UserStoryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return storyDataList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storyDataList[section].celldata.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData: UserStoryCellItem  = storyDataList[indexPath.section].celldata[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellData.cellIdentifier, for: indexPath) as? UserStoryCell else {
            return UITableViewCell()
        }
        cell.configuration1(self.title ?? "", cellData: cellData, tamilTermsString: tamilTermsString, section: indexPath.section, row: indexPath.row, target: self, selectors: [#selector(tapOnButton1(_:)), #selector(tapOnButton2(_:)), #selector(self.doneToolbar(_:)), #selector(self.nextToolbar(_:))], optionButton1: &optionButton1, optionButton2: &optionButton2)
        if let textField = cell.textField {
            storyDataList[indexPath.section].textField = textField
        }
        if let textView = cell.textView {
            storyDataList[indexPath.section].textView = textView
        }
        return cell
    }
}

// MARK: - UITableViewDelegate -
extension UserStoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellData: UserStoryCellItem  = storyDataList[indexPath.section].celldata[indexPath.row]
        return cellData.cellHeight
    }
}

// MARK: - UITextFieldDelegate -
extension UserStoryViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.setError()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [self] in
            let indexPath = IndexPath(row: 0, section: textField.tag)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextCellData = storyDataList[textField.tag + 2]
        let indexPath = IndexPath(row: 0, section: textField.tag + 2)
        if let cell = tableView.dequeueReusableCell(withIdentifier: nextCellData.id, for: indexPath) as? UserStoryCell, let textField = cell.textField {
            tableView.reloadRows(at: [indexPath], with: .none)
            textField.becomeFirstResponder()
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.storyDataList[textField.tag].value = textField.text!
        if textField.text!.isBlank {
            Validator.showRequiredError(textField)
        }
    }
}

// MARK: - UITextViewDelegate -
extension UserStoryViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.setError()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [self] in
            let indexPath = IndexPath(row: 0, section: textView.tag)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.storyDataList[textView.tag].value = textView.text!
        if textView.text!.isBlank {
            Validator.showRequiredErrorTextView(textView)
        }
        return true
    }
}

// MARK: - PromptViewDelegate -
extension UserStoryViewController: PromptViewDelegate {
    func didActionOnPromptButton(_ tag: Int) {
        //back to profile screen
        self.navigationController?.popViewController(animated: true)
    }
}
