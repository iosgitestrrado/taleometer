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
    private let cellTextField = "textFieldCell"
    private let cellTextView = "textViewCell"
    private let cellRadio = "radioCell"
    private let cellTerms = "termsCell"
    private let cellButton = "buttonCell"
    
    private let cellTFHeight: CGFloat = 83.0
    private let cellTVHeight: CGFloat = 170.0
    private let cellRHeight: CGFloat = 63.0
    private let cellTMHeight: CGFloat = 30.0
    private let cellBTHeight: CGFloat = 50.0
    
    enum UserStoryCellItem: Equatable {
        case name
        case storyAbout
        case lifeMoment
        case sharePeople
        case incident
        case anythingElse
        case terms
        case submitButton

        var title: String {
            switch self {
            case .name:
                return "Name"
            case .storyAbout:
                return "Who is this story about?"
            case .lifeMoment:
                return "What's the life moment or story that you want to share with us? (e.g. wedding, 12th std math exam, fractured my leg)"
            case .sharePeople:
                return "Who where the people that were there when this happened, preferably with names."
            case .incident:
                return "Now when you think about that incident, how does it make you feel?"
            case .anythingElse:
                return "Anything else that you would like to share about incident? (e.g.: why this is important to you?, what was the impact of this incident?...)"
            default:
                return ""
            }
        }
        
        var cellIdentifier: String {
            switch self {
            case .name:
                return "textFieldCell"
            case .storyAbout:
                return "radioCell"
            case .lifeMoment:
                return "textViewCell"
            case .sharePeople:
                return "textViewCell"
            case .incident:
                return "textViewCell"
            case .anythingElse:
                return "textViewCell"
            case .terms:
                return "termsCell"
            case .submitButton:
                return "buttonCell"
            }
        }
        
        var errorMessge: String {
            switch self {
            case .name:
                return "Please enter your name"
            case .storyAbout:
                return "Please enter about your story"
            case .lifeMoment:
                return "Please share life moment of your story"
            case .sharePeople:
                return "Please enter people name who's with you when your story happened"
            case .incident:
                return "Plesae enter incident of your story"
            case .anythingElse:
                return "Please enter anything about incident of story"
            case .terms:
                return ""
            case .submitButton:
                return ""
            }
        }
        
        var cellHeight: CGFloat {
            switch self {
            case .name:
                return 83.0
            case .storyAbout:
                return 63.0
            case .lifeMoment:
                return 170.0
            case .sharePeople:
                return 170.0
            case .incident:
                return 170.0
            case .anythingElse:
                return 170.0
            case .terms:
                return 30.0
            case .submitButton:
                return 50.0
            }
        }
    }
    
    private struct storyModel {
        var value = String()
        var id = String()
        var celldata = [UserStoryCellItem]()
    }
    private var storyDataList = [storyModel]()
    private var originalBtnConstraint = 0.0
//    private let storyData: [[UserStoryCellItem]] = [
//        [.name, .storyAbout, .lifeMoment, .sharePeople, .incident, .anythingElse, .terms, .submitButton]
//    ]
    private var optionButton1: UIButton?
    private var optionButton2: UIButton?

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setStoryData()
        self.hideKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: false)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHideNotification), name: UIResponder.keyboardDidHideNotification, object: nil)
        originalBtnConstraint = self.tblBottomConstraint.constant
    }
    
    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        self.sideMenuController!.toggleRightView(animated: true)
    }
    
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
    
    private func setOptionSelection(_ isOption1Selected: Bool){
        self.optionButton1?.isSelected = isOption1Selected
        self.optionButton2?.isSelected = !isOption1Selected
        if isOption1Selected {
            self.storyDataList[1].value = "MySelf"
        } else {
            self.storyDataList[1].value = "Someone Else"
        }
    }
    
    @objc private func tapOnButton1(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            setOptionSelection(true)
            break
        case 6:
            Core.push(self, storyboard: Storyboard.auth, storyboardId: "TermsAndConditionVC")
            break
        default:
            for story in storyDataList {
                if story.value.isBlank && story.id != UserStoryCellItem.submitButton.cellIdentifier && story.id != UserStoryCellItem.terms.cellIdentifier {
                    Snackbar.showAlertMessage(story.celldata[0].errorMessge)
                    return
                }
            }
            PromptVManager.present(self, isAudioView: false, verifyTitle: "Thank You", verifyMessage: "For Your Valuable Contribution")
            //print(storyDataList)
            break
        }
    }
    
    @objc private func tapOnButton2(_ sender: UIButton) {
        if sender.tag == 1 {
            setOptionSelection(false)
        }
    }
    
    @objc private func keyboardWillShowNotification (notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue  {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.tblBottomConstraint.constant = keyboardHeight
            self.tableView.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardDidHideNotification (notification: Notification) {
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
        if let titleLbl = cell.titleLabel {
            titleLbl.text = cellData.title
        }
        if let btn1 = cell.option1Btn {
            if cellData == .storyAbout {
                optionButton1 = btn1
            }
            btn1.tag = indexPath.section
            btn1.addTarget(self, action: #selector(tapOnButton1(_:)), for: .touchUpInside)
        }
        if let btn2 = cell.option2Btn {
            if cellData == .storyAbout {
                optionButton2 = btn2
            }
            btn2.tag = indexPath.section
            btn2.addTarget(self, action: #selector(tapOnButton2(_:)), for: .touchUpInside)
        }
        if let textField = cell.textField {
            textField.text = storyDataList[indexPath.section].value
            textField.tag = indexPath.section
            textField.delegate = self
        }
        if let textView = cell.textView {
            textView.text = storyDataList[indexPath.section].value
            textView.tag = indexPath.section
            textView.delegate = self
        }
        cell.selectionStyle = .none
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

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let textVal = NSMutableString.init(string: textField.text!)
//        if string.count > 0 {
//            textVal.insert(string, at: range.location)
//        } else {
//            textVal.replaceCharacters(in: range, with: "")
//        }
        //self.storyDataList[textField.tag].value = textVal as String
        //self.tableView.reloadRows(at: [IndexPath(row: 0, section: textField.tag)], with: .none)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.storyDataList[textField.tag].value = textField.text!
        //tableView.reloadRows(at: [IndexPath(row: 0, section: textField.tag)], with: .none)
    }
}

// MARK: - UITextViewDelegate -
extension UserStoryViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        let textVal = NSMutableString.init(string: textField.text!)
//        if string.count > 0 {
//            textVal.insert(string, at: range.location)
//        } else {
//            textVal.replaceCharacters(in: range, with: "")
//        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.storyDataList[textView.tag].value = textView.text!
       // tableView.reloadData()
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
