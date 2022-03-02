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
    /*
     * Create user story every cell item
     * Cell Item Title
     * Cell Identifier
     * Cell Validation message
     * Cell Height
     */
    private enum UserStoryCellItem: Equatable {
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
        
        var titleTamil: String {
            switch self {
            case .name:
                return "பெயர்"
            case .storyAbout:
                return "இந்தக் கதை யாரைப் பற்றியது?"
            case .lifeMoment:
                return "நீங்கள் எங்களுடன் பகிர்ந்து கொள்ள விரும்பும் வாழ்க்கை தருணம் அல்லது கதை என்ன? (எ.கா. திருமணம், 12வது வகுப்பு கணிதத் தேர்வு, என் காலில் எலும்பு முறிவு)"
            case .sharePeople:
                return "இது நடந்தபோது அங்கு இருந்தவர்கள் யார், முன்னுரிமை பெயர்களுடன்."
            case .incident:
                return "இப்போது அந்தச் சம்பவத்தை நினைக்கும் போது, அது உங்களுக்கு எப்படித் தோன்றுகிறது?"
            case .anythingElse:
                return "சம்பவத்தைப் பற்றி வேறு ஏதாவது பகிர்ந்து கொள்ள விரும்புகிறீர்களா? (எ.கா: இது உங்களுக்கு ஏன் முக்கியமானது?, இந்த சம்பவத்தின் தாக்கம் என்ன?...)"
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
                return "Please select radio button for 'Who is this story about?'"
            case .lifeMoment:
                return "Please share life moment of your story"
            case .sharePeople:
                return "Please enter people name who's with you when your story happened"
            case .incident:
                return "Please enter incident of your story"
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
    
    // MARK: - create property for story data
    private struct storyModel {
        var value = String()
        var id = String()
        var celldata = [UserStoryCellItem]()
    }
    private var storyDataList = [storyModel]()
    
    // MARK: - Radio button
    private var optionButton1: UIButton?
    private var optionButton2: UIButton?
    
    // MARK: - Text view next and done button toolbar
    private var doneToolbar = UIToolbar()
    private var nextToolbar = UIToolbar()
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHideNotification), name: UIResponder.keyboardDidHideNotification, object: nil)
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
        
        //Intialize toolbars for text view
        doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40.0))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var doneString = "Done"
        var nextString = "Next"
        if self.title == "Tamil" {
            doneString = "முடிந்தது"
            nextString = "அடுத்தது"
        }
        var done: UIBarButtonItem = UIBarButtonItem(title: doneString, style: .done, target: self, action: #selector(self.doneToolbar(_:)))
        var items1: [UIBarButtonItem] = [flexSpace, done]
        doneToolbar.items = items1
        
        nextToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40.0))
        nextToolbar.barStyle = UIBarStyle.default
        done = UIBarButtonItem(title: nextString, style: .done, target: self, action: #selector(self.nextToolbar(_:)))
        items1 = [flexSpace, done]
        nextToolbar.items = items1
    }
    
    // MARK: - Logic for click on radio button
    private func setOptionSelection(_ isOption1Selected: Bool){
        self.optionButton1?.isSelected = isOption1Selected
        self.optionButton2?.isSelected = !isOption1Selected
        
        var mySelfStr = "MySelf"
        var someoneStr = "Someone Else"
        if self.title == "Tamil" {
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
            if let cell = tableView.dequeueReusableCell(withIdentifier: nextCellData.id, for: indexPath) as? UserStoryCell, let textView = cell.textView {
                tableView.reloadRows(at: [indexPath], with: .none)
                textView.becomeFirstResponder()
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
            Core.push(self, storyboard: Storyboard.auth, storyboardId: "TermsAndConditionVC")
            break
        default:
            for story in storyDataList {
                if story.value.isBlank && story.id != UserStoryCellItem.submitButton.cellIdentifier && story.id != UserStoryCellItem.terms.cellIdentifier {
                    Snackbar.showAlertMessage(story.celldata[0].errorMessge)
                    return
                }
            }
            PromptVManager.present(self, isAudioView: false, verifyTitle: "Thank You", verifyMessage: "For Your Valuable Contribution", imageName: "thank")
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
            if self.title == "Tamil" {
                titleLbl.text = cellData.titleTamil
            }
        }
        if self.title == "Tamil" {
            if let opt1Lbl = cell.option1Lbl {
                opt1Lbl.text = "நானே"
            }
            if let opt2Lbl = cell.option2Lbl {
                opt2Lbl.text = "வேறு யாரோ"
            }
        }
        if let btn1 = cell.option1Btn {
            if cellData == .storyAbout {
                optionButton1 = btn1
            }
            btn1.tag = indexPath.section
            btn1.addTarget(self, action: #selector(tapOnButton1(_:)), for: .touchUpInside)
            if self.title == "Tamil" && indexPath.section == 6 {
                //cell.option1Btn.titleLabel?.attributedText = NSAttributedString("எங்கள் விதிமுறைகள் மற்றும் நிபந்தனைகளைப் படிக்கவும்")
                let attString = NSMutableAttributedString(string: tamilTermsString)
                let fontBlue = [ NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 116.0 / 255.0, green: 117.0 / 255.0, blue: 182.0 / 255.0, alpha: 1.0) ]
                let fontRed = [ NSAttributedString.Key.foregroundColor:  UIColor(displayP3Red: 232.0 / 255.0, green: 56.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0) ]
                let rangeTitle1 = NSRange(location: 0, length: 65)
                let rangeTitle2 = NSRange(location: 33, length: 32)
                attString.addAttributes(fontBlue, range: rangeTitle1)
                attString.addAttributes(fontRed, range: rangeTitle2)
                if #available(iOS 15, *) {
                    btn1.setAttributedTitle(attString, for: .normal)
                } else {
                    // Fallback on earlier versions
                    btn1.setAttributedTitle(attString, for: .normal)
                }
            }
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
            textField.returnKeyType = .next
            textField.delegate = self
        }
        if let textView = cell.textView {
            textView.text = storyDataList[indexPath.section].value
            textView.tag = indexPath.section
            if indexPath.section == 5 {
                if let doneBtn = doneToolbar.items?[1] {
                    doneBtn.tag = indexPath.section
                }
                textView.inputAccessoryView = doneToolbar
            } else {
//                if let nextBtn = nextToolbar.items?[1] {
//                    nextBtn.tag = indexPath.section
//                }
                let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                var nextString = "Next"
                if self.title == "Tamil" {
                    nextString = "அடுத்தது"
                }
                nextToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40.0))
                nextToolbar.barStyle = UIBarStyle.default
                let done = UIBarButtonItem(title: nextString, style: .done, target: self, action: #selector(self.nextToolbar(_:)))
                done.tag = indexPath.section
                let items1 = [flexSpace, done]
                nextToolbar.items = items1
                textView.inputAccessoryView = nextToolbar
            }
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
        let nextCellData = storyDataList[textField.tag + 2]
        let indexPath = IndexPath(row: 0, section: textField.tag + 2)
        if let cell = tableView.dequeueReusableCell(withIdentifier: nextCellData.id, for: indexPath) as? UserStoryCell, let textView = cell.textView {
            tableView.reloadRows(at: [indexPath], with: .none)
            textView.becomeFirstResponder()
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.storyDataList[textField.tag].value = textField.text!
    }
}

// MARK: - UITextViewDelegate -
extension UserStoryViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
            let indexPath = IndexPath(row: 0, section: textView.tag)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.storyDataList[textView.tag].value = textView.text!
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
