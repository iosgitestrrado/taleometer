//
//  StoryViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit
import Popover

class StoryViewController: UIViewController {

    // MARK: - Weak Property -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleTableView: UILabel!
    @IBOutlet weak var tblBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Public Properties -
    var parentController: UIViewController?

    // MARK: - Privare Property -
    // MARK: - create property for story data
    private var storyDataList = [UserStoryModel]()
    var userStoryIds = [Int]()
    var userStoryValues = [String]()
    private let tamilTermsString = "தயவுசெய்து எங்களுடையது படியுங்கள் விதிமுறைகள் மற்றும் நிபந்தனைகள்"
    private var isRightViewEnable = false
    
    /* Popover properties */
    private var popupArray = [String]()
    private var tableViewPO = UITableView()
    private var popover: Popover!
    private var popoverOptionsDown: [PopoverOption] = [
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    private var popoverOptionsUp: [PopoverOption] = [
        .type(.up),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //setStoryData()
        self.hideKeyboard()
        self.titleTableView.text = self.title == "English" ? "You share an event from your life. We will turn it into a story." : "உங்க வாழ்க்கையில நடந்த ஒரு விஷையத்த பகிருங்க. நாங்க அதை ஒரு நல்ல கதையா மாத்துவோம்."
        
        /* Popover tableview */
        tableViewPO = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width - 50.0, height: 320.0))
        tableViewPO.delegate = self
        tableViewPO.dataSource = self
        
        self.tableView.panGestureRecognizer.cancelsTouchesInView = false
        NotificationCenter.default.addObserver(self, selector: #selector(updatedRadioButton(_:)), name: NSNotification.Name(rawValue: "UpdateRadioButton"), object: nil)

        getUserStory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isRightViewEnable {
            self.sideMenuController!.toggleRightView(animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Call funcation when audio controller press in background
    @objc private func updatedRadioButton(_ notification: Notification) {
       if let rowIndex = notification.userInfo?["rowIndexInt"] as? Int, rowIndex >= 0, let selectedAnswer = notification.userInfo?["selectedAnswer"] as? String {
           if self.title == "English" {
               self.storyDataList[rowIndex].Value = selectedAnswer
           } else {
               self.storyDataList[rowIndex].Value_Tamil = selectedAnswer
           }
       }
    }
    
    // MARK: - Click on done button of keyborad toolbar
    @objc private func doneToolbar(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
    
    @objc private func tapOnOptionBtn(_ sender: UIButton) {
        let rectInTableView = self.tableView.rectForRow(at: IndexPath(row: sender.tag, section: 0))
        self.popover = Popover(options: (rectInTableView.origin.y - tableView.contentOffset.y) > (self.tableView.frame.size.height / 2.5) ?  self.popoverOptionsUp : self.popoverOptionsDown)
        self.popover.arrowSize = .zero
        self.popover.tag = sender.tag
        if self.popover == nil {
            self.popover.dismiss()
        }
        self.tableViewPO.frame.size.height = 320.0
        self.popupArray = self.title == "English" ? storyDataList[sender.tag].Options : storyDataList[sender.tag].Options_tamil
        if popupArray.count > 0 && popupArray.count < 8 {
            self.tableViewPO.frame.size.height = CGFloat(40.0 * Double(popupArray.count))
        }
        if popupArray.count > 0 {
            tableViewPO.reloadData()
            self.popover.show(tableViewPO, fromView: sender, inView: self.view)
        }
    }
    
    // MARK: - Click on next button of keyboard toolbar
    @objc private func nextToolbar(_ sender: UIBarButtonItem) {
        //var nextCellId = ""
        var nextIntIdx = 0
        for idx in (sender.tag + 1)..<storyDataList.count {
            if storyDataList[idx].TypeT.lowercased() == "text" {
               // nextCellId = "textViewCell"
                nextIntIdx = idx
                break
            }
        }
        
        let indexPath = IndexPath(row: nextIntIdx, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [self] in
            if let cell = tableView.cellForRow(at: indexPath) as? UserStoryCell, let textView = cell.textView {
                //tableView.reloadRows(at: [indexPath], with: .none)
                textView.becomeFirstResponder()
            }
        }
    }

    // MARK: Click on submit button
    @objc private func tapOnSubmit(_ sender: UIButton) {
        userStoryIds = [Int]()
        userStoryValues = [String]()
        for i in 0..<storyDataList.count {
            let story = storyDataList[i]
            if self.title == "English" {
                if story.Value.isBlank && story.CellId != UserStoryCellItem.submitButton.cellIdentifier && story.CellId != UserStoryCellItem.terms.cellIdentifier {
                    if let text = story.TextView {
                        Validator.showRequiredErrorTextView(text)
                        tableView.scrollToRow(at: IndexPath(row: i, section: 0), at: .top, animated: true)
                        userStoryIds = [Int]()
                        userStoryValues = [String]()
                        return
                    }
                    Toast.show(story.TypeT.lowercased() == "text" ? "Please enter \(story.Title)" : "Please select \(story.Title)")
                    tableView.scrollToRow(at: IndexPath(row: i, section: 0), at: .top, animated: true)
                    userStoryIds = [Int]()
                    userStoryValues = [String]()
                    return
                }
            } else {
                if story.Value_Tamil.isBlank && story.CellId != UserStoryCellItem.submitButton.cellIdentifier && story.CellId != UserStoryCellItem.terms.cellIdentifier {
                    if let text = story.TextView {
                        Validator.showRequiredErrorTextView(text)
                        tableView.scrollToRow(at: IndexPath(row: i, section: 0), at: .top, animated: true)
                        userStoryIds = [Int]()
                        userStoryValues = [String]()
                        return
                    }
                    Toast.show(story.TypeT.lowercased() == "text" ? "Please enter \(story.Title_tamil)" : "Please select \(story.Title_tamil)")
                    tableView.scrollToRow(at: IndexPath(row: i, section: 0), at: .top, animated: true)
                    userStoryIds = [Int]()
                    userStoryValues = [String]()
                    return
                }
            }
            
            if story.CellId != UserStoryCellItem.terms.cellIdentifier && story.CellId != UserStoryCellItem.submitButton.cellIdentifier {
                userStoryIds.append(story.Id)
                userStoryValues.append(self.title == "English" ? story.Value : story.Value_Tamil)
            }
        }
        self.postUserStory()
    }
    
    // MARK: Click on terms and condition
    @objc private func tapOnTerms(_ sender: UIButton) {
        Core.push(self, storyboard: Constants.Storyboard.auth, storyboardId: "TermsAndConditionVC")
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

// MARK: - Get data from server -
extension StoryViewController {
    func getUserStory() {
        if storyDataList.count > 0 {
            self.tableView.reloadData()
            return
        }
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self, methodName: "getUserStory")
            return
        }
        Core.ShowProgress(parentController!, detailLbl: "")
        OtherClient.getUserStory { [self] response in
            if let data = response {
                storyDataList = data.sorted(by: { $0.Order < $1.Order })
                var idx = storyDataList.count - 1
                for _ in storyDataList {
                    if storyDataList[idx].TypeT.lowercased() == "text" {
                        storyDataList[idx].IsLast = true
                        break
                    }
                    idx = idx - 1
                }
                
                var storyM = UserStoryModel()
                storyM.Title = self.title == "English" ? "" : tamilTermsString
                storyM.CellId = UserStoryCellItem.terms.cellIdentifier
                storyDataList.append(storyM)
                
                storyM = UserStoryModel()
                storyM.CellId = UserStoryCellItem.submitButton.cellIdentifier
                storyDataList.append(storyM)
            }
            self.tableView.reloadData()
            Core.HideProgress(parentController!)
        }
    }
    
    private func postUserStory() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self, methodName: "postUserStory")
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        OtherClient.postUserStory(UserStoryRequest(user_story_ids: userStoryIds, values: userStoryValues)) { status in
            if let st = status, st {
                PromptVManager.present(self, verifyTitle: "Thank You", verifyMessage: "For Your Valuable Contribution", verifyImage: UIImage(named: "thank")!, isUserStory: true)
            }
            Core.HideProgress(self)
        }
    }
}

// MARK: - UITableViewDataSource -
extension StoryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.tableViewPO == tableView {
            return self.popupArray.count
        }
        return storyDataList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        if self.tableViewPO == tableView {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cellIdentifier")
            cell.textLabel?.text = "\(self.popupArray[indexPath.row])"
            cell.textLabel?.textColor = .white
            cell.contentView.backgroundColor = Constants.purpleColor
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: storyDataList[indexPath.row].CellId, for: indexPath) as? UserStoryCell else {
            return UITableViewCell()
        }
        cell.configuration(self.title ?? "English", cellData: storyDataList[indexPath.row], tamilTermsString: tamilTermsString, row: indexPath.row, target: self, selectors: [#selector(tapOnTerms(_:)), #selector(self.tapOnSubmit(_:)), #selector(self.doneToolbar(_:)), #selector(self.nextToolbar(_:)), #selector(self.tapOnOptionBtn(_:))], options: storyDataList[indexPath.row].Options, options_tamil: storyDataList[indexPath.row].Options_tamil)
        if let textView = cell.textView {
            textView.text = self.title == "English" ? storyDataList[indexPath.row].Value : storyDataList[indexPath.row].Value_Tamil
            storyDataList[indexPath.row].TextView = textView
        }
        return cell
    }
}

// MARK: - UITableViewDelegate -
extension StoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.tableViewPO == tableView {
            let indexPathStory = IndexPath(row: self.popover.tag, section: 0)
            if self.title == "English" {
                storyDataList[indexPathStory.row].Value = popupArray[indexPath.row]
            } else {
                storyDataList[indexPathStory.row].Value_Tamil = popupArray[indexPath.row]
            }
            self.tableView.reloadRows(at: [indexPathStory], with: .none)
            self.popover.dismiss()
            return
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.tableViewPO == tableView {
            return 40.0
        }
        return UITableView.automaticDimension
    }
}

// MARK: - UITextViewDelegate -
extension StoryViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.setError()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [self] in
            let indexPath = IndexPath(row: textView.tag, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if self.title == "English" {
            self.storyDataList[textView.tag].Value = textView.text!
        } else {
            self.storyDataList[textView.tag].Value_Tamil = textView.text!
        }
        if textView.text!.isBlank {
            Validator.showRequiredErrorTextView(textView)
        }
        return true
    }
}

// MARK: - PromptViewDelegate -
extension StoryViewController: PromptViewDelegate {
    func didActionOnPromptButton(_ tag: Int) {
        if tag == 9 {
            if !Reachability.isConnectedToNetwork() {
                Core.noInternet(self)
                return
            }
            AuthClient.logout("Logged out successfully", moveToLogin: false)
            Core.push(self, storyboard: Constants.Storyboard.auth, storyboardId: LoginViewController().className)
            return
        }
        //back to profile screen
        self.isRightViewEnable = true
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - NoInternetDelegate -
extension StoryViewController: NoInternetDelegate {
    func connectedToNetwork(_ methodName: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.perform(Selector((methodName)))
        }
    }
}
