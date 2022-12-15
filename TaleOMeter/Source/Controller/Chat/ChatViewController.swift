//
//  ChatViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 02/12/22.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textConstraint: NSLayoutConstraint!
    
    private var textPlaceholder = "Type Your Message..."
    private var messageString = ""
    private var chatList = [MessageData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "NoDataTableViewCell")
        
        self.textView.text = textPlaceholder
        self.textView.textColor = .darkGray
        self.textView.addInputAccessoryView("Done", target: self, selector: #selector(tapOnDoneTool(_:)))
        
        self.hideKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true, titleInLeft: true, backImage: true)
        getMessages()
        addActivityLog()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        if isMovingFromParent {
//            self.sideMenuController!.toggleRightView(animated: false)
//        }
    }
    
    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        self.sideMenuController!.toggleRightView(animated: true)
    }
    
    @IBAction func tapOnSendButton(_ sender: UIButton) {
        if textView.text!.isBlank || textView.text == textPlaceholder {
            Toast.show("Message should not be empty")
            return
        }
//        var chatDictonary = Dictionary<String, Any>()
//        chatDictonary["align"] = "right"
//        chatDictonary["message"] = textView.text!
//        chatDictonary["image"] = ""
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd/hh:mm a"
//        let myString = formatter.string(from: Date()).components(separatedBy: "/")
//
//        chatDictonary["created_at"] = myString.count > 1 ? myString[1] : "00:00 AM"
        
//        chatCellList.append(CellData(cellId: ChatTableViewCell.rightIdentifier, data: ChatModel(JSON(chatDictonary), storeName: storeName), isRight: true))
//        self.tableView.reloadData()
        messageString = self.textView.text
        self.textView.text = textPlaceholder
        self.textView.textColor = .darkGray
        self.sendMessage()
    }
    
    @objc private func tapOnDoneTool(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
    
    @objc private func keyboardWillShowNotification (notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue  {
            let keyboardRectangle = keyboardFrame.cgRectValue
            if let window = UIApplication.shared.keyWindow {
                textConstraint.constant = keyboardRectangle.height - window.safeAreaInsets.bottom
            } else {
                textConstraint.constant = keyboardRectangle.height
            }
        }
    }
    
    @objc private func keyboardWillHideNotification (notification: Notification) {
        textConstraint.constant = 0
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ChatViewController {
    // MARK: - Get Chat list data
    @objc func getChatData() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self, methodName: "getChatData")
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        ChatClient.getChatLists { response in
            if let data = response, data.count > 0 {
//                self.chatList = data
            }
            self.tableView.reloadData()
            Core.HideProgress(self)
        }
//        OtherClient.getFAQ { response in
//            if let data = response, data.count > 0 {
//                data.forEach { object in
//                    self.faqSectionList.append(SectionData(isOpen: false, numberOfRows: !object.Answer_audio.isEmpty && !object.Answer_eng.isEmpty ? 2 : 1, item: object))
//                }
//            }
//            self.tableView.reloadData()
//            Core.HideProgress(self)
//        }
    }
    
    @objc func getMessages() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self, methodName: "getMessages")
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        ChatClient.getMessages { response in
            if let data = response, data.Messages.count > 0 {
                self.chatList = data.Messages
            }
            self.tableView.reloadData()
            Core.HideProgress(self)
        }
    }
    
    @objc func sendMessage() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self, methodName: "sendMessage")
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        ChatClient.sendMessage(SendMessageRequest(message: messageString)) { response in
            Core.HideProgress(self)
        }
    }
    
    // MARK: Add into activity log
    private func addActivityLog() {
        if !Reachability.isConnectedToNetwork() {
            return
        }
        DispatchQueue.global(qos: .background).async {
            ActivityClient.userActivityLog(UserActivityRequest(post_id: "", category_id: "", screen_name: Constants.ActivityScreenName.message, type: Constants.ActivityType.story)) { status in
            }
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.chatList.count > 0 ? chatList.count : 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatList[section].Chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: self.chatList[indexPath.section].Chats[indexPath.row].Align.lowercased() == "right" ? ChatTableViewCell.rightIdentifier : ChatTableViewCell.leftIdentifier, for: indexPath) as? ChatTableViewCell {
            cell.configure(self.chatList[indexPath.section].Chats[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
}

extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.chatList.count <= 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataTableViewCell") as? NoDataTableViewCell else { return UITableViewCell() }
            return cell
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.dateIdentifier) as? ChatTableViewCell {
            cell.dateLabel.text = chatList[section].Day
            return cell
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.chatList.count > 0 ? UITableView.automaticDimension : 30.0
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UITextViewDelegate -
extension ChatViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .darkGray {
            textView.text = nil
            textView.textColor = .white
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

            textView.text = textPlaceholder
            textView.textColor = .darkGray

            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }

        // Else if the text view's placeholder is showing and the
        // length of the replacement string is greater than 0, set
        // the text color to white then set its text to the
        // replacement string
         else if textView.textColor == .darkGray && !text.isEmpty {
            textView.textColor = .white
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
            textView.text = textPlaceholder
            textView.textColor = .darkGray
        }
    }
}

// MARK: - NoInternetDelegate -
extension ChatViewController: NoInternetDelegate {
    func connectedToNetwork(_ methodName: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.perform(Selector((methodName)))
        }
    }
}
