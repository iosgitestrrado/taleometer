//
//  TRFeedViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 03/03/22.
//

import UIKit
import AVKit

class TRFeedViewController: UIViewController {
    
    // MARK: - Weak Properties -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tblBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Private Properties -
    fileprivate let viewMoreText = "--------------------  View More  --------------------"
    fileprivate struct CommentModel: Codable {
        var image = String()
        var name = String()
        var comment = String()
        var time: Date?
        var isExpanded = false
        var replies = [CommentModel]()
    }
    fileprivate struct FeedModel: Codable {
        var image = String()
        var videoUrl = String()
        var question = String()
        var answer = String()
        var isExpanded = false
        var comments = [CommentModel]()
        var time: Date?
        var description = String()
    }
    fileprivate struct Data {
        var image = String()
        var title = String()
        var description = String()
        var time: Date?
        var index = Int()
        var commentIndex = Int()
        var replyIndex = Int()
    }
    fileprivate struct CellItem {
        var cellId = String()
        var data = Data()
    }

    fileprivate var feedArray: [FeedModel] = [FeedModel]()
    fileprivate var cellDataArray: [CellItem] = [CellItem]()
    fileprivate let messageString = "Write A Comment..."

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.hideKeyboard()
        self.setDummyFeeds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true, titleInLeft: false, backImage: true, backImageColor: .red)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.storeFeedDummyData()
    }
    
    // MARK: - Set Dummy data -
    private func setDummyFeeds() {
        
        if let feedData = readFeedDummyData() {
            feedArray = feedData
        } else {
            feedArray = [FeedModel]()
            
            // Add into Comments array
            var commentArr = [CommentModel]()
            commentArr.append(CommentModel(image: "person", name: "You", comment: "Tenali Raman", time: Date(), replies: [CommentModel]()))
            
            // Add into Reply Array
            var replyArr = [CommentModel]()
            replyArr.append(CommentModel(image: "person", name: "Amblin", comment: "Wrong Answer", time: Date(), replies: [CommentModel]()))
            replyArr.append(CommentModel(image: "person", name: "You", comment: "Right Answer is Tenali Raman", time: Date(), replies: [CommentModel]()))
            replyArr.append(CommentModel(image: "person", name: "John Doe", comment: "Thank you!", time: Date(), replies: [CommentModel]()))
            replyArr.append(CommentModel(image: "person", name: "Amblin", comment: "Welcome!", time: Date(), replies: [CommentModel]()))
            replyArr.append(CommentModel(image: "person", name: "John Doe", comment: "Yes! I have checked right answer is Tenali Raman", time: Date(), replies: [CommentModel]()))
            replyArr.append(CommentModel(image: "person", name: "You", comment: "Where you have check this answer?", time: Date(), replies: [CommentModel]()))
            replyArr.append(CommentModel(image: "person", name: "You", comment: "I checked this answer online!", time: Date(), replies: [CommentModel]()))
            // Add into Comments array
            commentArr.append(CommentModel(image: "person", name: "John Doe", comment: "Birbal", time: Date(), replies: replyArr))
            
            // Add into Reply Array
            replyArr = [CommentModel]()
            replyArr.append(CommentModel(image: "person", name: "Amblin", comment: "Wrong Answer! Please try again", time: Date(), replies: [CommentModel]()))
            replyArr.append(CommentModel(image: "person", name: "You", comment: "Right Answer is Tenali Raman", time: Date(), replies: [CommentModel]()))
            replyArr.append(CommentModel(image: "person", name: "Joseph", comment: "Thank you!", time: Date(), replies: [CommentModel]()))
            // Add into Comments array
            commentArr.append(CommentModel(image: "person", name: "Joseph", comment: "Dora", time: Date(), replies: replyArr))
            
            // Add into Comment Array
            commentArr.append(CommentModel(image: "person", name: "Benpham", comment: "Tenali Raman", time: Date(), replies: [CommentModel]()))
            commentArr.append(CommentModel(image: "person", name: "Steven", comment: "Tenali Raman", time: Date(), replies: [CommentModel]()))
            commentArr.append(CommentModel(image: "person", name: "Brent French", comment: "Tenali Raman", time: Date(), replies: [CommentModel]()))
            
            // Add into feed array
            feedArray.append(FeedModel(image: "tenali", videoUrl: "", question: "Who is the Character in this Image?", answer: "Tenali Raman", comments: commentArr, time: nil))
            
            commentArr = [CommentModel]()
            // Add into Reply Array
            replyArr = [CommentModel]()
            replyArr.append(CommentModel(image: "person", name: "Amblin", comment: "I think it's a cake design", time: Date(), replies: [CommentModel]()))
            replyArr.append(CommentModel(image: "person", name: "You", comment: "Yes it is cake design", time: Date(), replies: [CommentModel]()))
            replyArr.append(CommentModel(image: "person", name: "John Doe", comment: "Thank you!", time: Date(), replies: [CommentModel]()))
            replyArr.append(CommentModel(image: "person", name: "Amblin", comment: "Yes! I seen in the video", time: Date(), replies: [CommentModel]()))
            replyArr.append(CommentModel(image: "person", name: "You", comment: "Great observation!", time: Date(), replies: [CommentModel]()))
            replyArr.append(CommentModel(image: "person", name: "Amblin", comment: "Ya! Great!", time: Date(), replies: [CommentModel]()))
            // Add into Comments array
            commentArr.append(CommentModel(image: "person", name: "You", comment: "Dummy Video", time: Date(), replies: replyArr))
            
            // Add into Comments array
            commentArr.append(CommentModel(image: "person", name: "Joseph", comment: "Cake Design", time: Date(), replies: [CommentModel]()))
            
            // Add into Reply Array
            replyArr = [CommentModel]()
            replyArr.append(CommentModel(image: "person", name: "Amblin", comment: "Wrong Answer! Please check again!", time: Date(), replies: [CommentModel]()))
            replyArr.append(CommentModel(image: "person", name: "You", comment: "Right Answer is Cake Design", time: Date(), replies: [CommentModel]()))
            replyArr.append(CommentModel(image: "person", name: "Joseph", comment: "Thank you!", time: Date(), replies: [CommentModel]()))
            // Add into Comments array
            commentArr.append(CommentModel(image: "person", name: "Joseph", comment: "Cake Recipe", time: Date(), replies: replyArr))
            
            commentArr.append(CommentModel(image: "person", name: "Benpham", comment: "Yes! Cake Design", time: Date(), replies: [CommentModel]()))
            commentArr.append(CommentModel(image: "person", name: "Steven", comment: "Right Answer", time: Date(), replies: [CommentModel]()))
            // Add into Comments array
            commentArr.append(CommentModel(image: "person", name: "Brent French", comment: "Cake Design", time: Date(), replies: [CommentModel]()))
            
            // Add into feed array
            feedArray.append(FeedModel(image: "acastro_180403_1777_youtube_0001", videoUrl: "https://v.pinimg.com/videos/720p/77/4f/21/774f219598dde62c33389469f5c1b5d1.mp4", question: "Watch video and answer the question in it", answer: "Dummy Video", comments: commentArr, time: nil))
            
            
            commentArr = [CommentModel]()
            // Add into Reply Array
            replyArr = [CommentModel]()
            replyArr.append(CommentModel(image: "person", name: "Amblin", comment: "I want to go Kyoto", time: Date(), replies: [CommentModel]()))
            replyArr.append(CommentModel(image: "person", name: "You", comment: "I Kyoto is very nice place!", time: Date(), replies: [CommentModel]()))
            replyArr.append(CommentModel(image: "person", name: "John Doe", comment: "I like entire Japan", time: Date(), replies: [CommentModel]()))
            replyArr.append(CommentModel(image: "person", name: "Amblin", comment: "I like Tokyo and Kyoto both!", time: Date(), replies: [CommentModel]()))
            replyArr.append(CommentModel(image: "person", name: "You", comment: "Great!", time: Date(), replies: [CommentModel]()))
            replyArr.append(CommentModel(image: "person", name: "Amblin", comment: "Ya! Great!", time: Date(), replies: [CommentModel]()))
            // Add into Comments array
            commentArr.append(CommentModel(image: "person", name: "You", comment: "Tokyo", time: Date(), replies: replyArr))
            
            // Add into Comments array
            commentArr.append(CommentModel(image: "person", name: "Joseph", comment: "Osaka", time: Date(), replies: [CommentModel]()))
           
            // Add into Reply Array
            replyArr = [CommentModel]()
            replyArr.append(CommentModel(image: "person", name: "Amblin", comment: "Good choice", time: Date(), replies: [CommentModel]()))
            replyArr.append(CommentModel(image: "person", name: "You", comment: "Also visit Tokyo", time: Date(), replies: [CommentModel]()))
            replyArr.append(CommentModel(image: "person", name: "Joseph", comment: "Thank you! I'll visit", time: Date(), replies: [CommentModel]()))
            // Add into Comments array
            commentArr.append(CommentModel(image: "person", name: "Joseph", comment: "Hiroshima", time: Date(), replies: replyArr))
            
            // Add into Comments array
            commentArr.append(CommentModel(image: "person", name: "Benpham", comment: "I also want to go Sapporo", time: Date(), replies: [CommentModel]()))
            // Add into Comments array
            commentArr.append(CommentModel(image: "person", name: "Steven", comment: "I want to check", time: Date(), replies: [CommentModel]()))
            // Add into Comments array
            commentArr.append(CommentModel(image: "person", name: "Brent French", comment: "Sapporo", time: Date(), replies: [CommentModel]()))
            
            // Add into feed array
            feedArray.append(FeedModel(image: "YouTube-thumbnail-maker-1", videoUrl: "", question: "Where to go in Japan?", answer: "Tokyo", comments: commentArr, time: nil))
            storeFeedDummyData()
        }
        self.setTableViewCells()
    }
    
    private func storeFeedDummyData() {
        do {
            for i in 0..<feedArray.count {
                feedArray[i].isExpanded = false
                for j in 0..<feedArray[i].comments.count {
                    feedArray[i].comments[j].isExpanded = false
                }
            }
            
            // Create JSON Encoder
            let encoder = JSONEncoder()
            // Encode Note
            let data = try encoder.encode(feedArray)

            // Write/Set Data
            UserDefaults.standard.set(data, forKey: "FeedData")
            UserDefaults.standard.synchronize()
        } catch {
            print("Unable to Encode Array of Feed (\(error))")
        }
    }
    
    private func readFeedDummyData() -> [FeedModel]? {
        if let data = UserDefaults.standard.data(forKey: "FeedData") {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode Note
                let notes = try decoder.decode([FeedModel].self, from: data)
                return notes
            } catch {
                print("Unable to Decode Notes (\(error))")
                return nil
            }
        }
        return nil
    }
    
    @objc private func tapOnAnswer(_ sender: UIButton) {
        PromptVManager.present(self, verifyTitle: feedArray[sender.tag].answer, verifyMessage: feedArray[sender.tag].question, imageName: feedArray[sender.tag].image, isQuestion: true, closeBtnHide: true)
    }
    
    private func setTableViewCells() {
        cellDataArray = [CellItem]()
        for index in 0..<feedArray.count {
            let feed = feedArray[index]
            cellDataArray.append(CellItem(cellId: FeedCellIdentifier.image, data: Data(image: feed.image, title: feed.question, description: "", time: nil, index: index)))
            if feed.comments.count > 0 {
                for comIndex in 0..<feed.comments.count {
                    let comment = feed.comments[comIndex]
                    if !feed.isExpanded && comIndex == 3 {
                        cellDataArray.append(CellItem(cellId: FeedCellIdentifier.viewMore, data: Data(image: "", title: viewMoreText, description: "", time: nil, index: index, commentIndex: comIndex)))
                        break
                    }
                    cellDataArray.append(CellItem(cellId: FeedCellIdentifier.comment, data: Data(image: comment.image, title: comment.name, description: comment.comment, time: comment.time, index: index, commentIndex: comIndex)))
                    if comment.replies.count > 0 {
                        for repIndex in 0..<comment.replies.count {
                            let reply = comment.replies[repIndex]
                            if !comment.isExpanded && repIndex == 0 && comment.replies.count > 1 {
                                cellDataArray.append(CellItem(cellId: FeedCellIdentifier.moreReply, data: Data(image: "", title: "View previous \(comment.replies.count - 1) replies", description: "", time: nil, index: index, commentIndex: comIndex)))
                                cellDataArray.append(CellItem(cellId: FeedCellIdentifier.reply, data: Data(image: reply.image, title: reply.name, description: reply.comment, time: reply.time, index: index, commentIndex: comIndex, replyIndex: repIndex)))
                                break
                            }
                            cellDataArray.append(CellItem(cellId: FeedCellIdentifier.reply, data: Data(image: reply.image, title: reply.name, description: reply.comment, time: reply.time, index: index, commentIndex: comIndex, replyIndex: repIndex)))
                        }
                    }
                }
                
            }
            cellDataArray.append(CellItem(cellId: FeedCellIdentifier.post, data: Data(image: "person", title: "", description: "", time: nil, index: index)))
        }
        self.tableView.reloadData()
        //self.tableView.reloadSections(IndexSet(integer: 0), with: .bottom)
    }
    
    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        self.sideMenuController!.toggleRightView(animated: true)
    }
    
    // MARK: Keyboard will show
    @objc private func keyboardWillShowNotification(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue  {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.tblBottomConstraint.constant = keyboardHeight
        }
    }
    
    // MARK: Keyboard will Hide
    @objc private func keyboardWillHideNotification(notification: Notification) {
        self.tblBottomConstraint.constant = 0
    }
    
    // MARK: Tap on view more comment
    @objc private func tapOnViewMore(_ sender: UIButton) {
        if !feedArray[sender.tag].isExpanded {
            feedArray[sender.tag].isExpanded = true
            self.setTableViewCells()
        }
    }
    
    // MARK: Tap on view previous reply
    @objc private func tapOnViewPrevReply(_ sender: UIButton) {
        if let comIndex = sender.layer.value(forKey: "CommentIndex") as? Int,  !feedArray[sender.tag].comments[comIndex].isExpanded {
            feedArray[sender.tag].comments[comIndex].isExpanded = true
            self.setTableViewCells()
        }
    }
    
    // MARK: Tap on post button
    @objc private func tapOnPost(_ sender: UIButton) {
        if feedArray[sender.tag].description.isBlank {
            Snackbar.showAlertMessage(messageString)
            return
        }
        
        if let rowIndex = sender.layer.value(forKey: "RowIndex") as? Int {
            if cellDataArray[rowIndex].cellId == FeedCellIdentifier.post {
                feedArray[sender.tag].comments.insert(CommentModel(image: "person", name: "You", comment: feedArray[sender.tag].description, time: Date(), isExpanded: false, replies: [CommentModel]()), at: 0)
            } else if cellDataArray[rowIndex].cellId == FeedCellIdentifier.replyPost, let commIndex = sender.layer.value(forKey: "CommentIndex") as? Int {
                feedArray[sender.tag].comments[commIndex].isExpanded = true
                feedArray[sender.tag].comments[commIndex].replies.insert(CommentModel(image: "person", name: "You", comment: feedArray[sender.tag].description, time: Date(), isExpanded: false, replies: [CommentModel]()), at: 0)
            }
            self.setTableViewCells()
        }
    }
    
    // MARK: Tap on reply Button
    @objc private func tapOnReply(_ sender: UIButton) {
        if let cellIndex = sender.layer.value(forKey: "CellIndex") as? Int, let commentIndex = sender.layer.value(forKey: "CommentIndex") as? Int, let replyIndex = sender.layer.value(forKey: "ReplyIndex") as? Int {
            if cellDataArray.contains(where: { cell in cell.cellId == FeedCellIdentifier.replyPost}) {
                cellDataArray.removeAll(where: { cell in cell.cellId == FeedCellIdentifier.replyPost })
            }
            cellDataArray.insert(CellItem(cellId: FeedCellIdentifier.replyPost, data: Data(image: "person", title: "", description: "", time: nil, index: cellIndex, commentIndex: commentIndex, replyIndex: replyIndex)), at: sender.tag + 1)
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Click on done button of keyborad toolbar
    @objc private func doneToolbar(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
    
    // MARK: - Play a video in video controller
    private func playVideo(_ row: Int) {
        guard let videoURL = URL(string: feedArray[row].videoUrl) else { return }
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.showsPlaybackControls = true
        self.present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }
}

// MARK: - UITableViewDataSource -
extension TRFeedViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellDataArray[indexPath.row].cellId, for: indexPath) as? FeedCellView else { return UITableViewCell() }
        let cellData = cellDataArray[indexPath.row].data
        cell.configureCell(cellData.image, title: cellData.title,
                           description: cellData.description, time: cellData.time,
                           cellId: cellDataArray[indexPath.row].cellId,
                           messageString: messageString, row: indexPath.row,
                           cellIndex: cellData.index, commentIndex: cellData.commentIndex,
                           replyIndex: cellData.replyIndex, target: self,
                           selectors: [#selector(tapOnPost(_:)), #selector(tapOnViewMore(_:)),  #selector(tapOnViewPrevReply(_:)),  #selector(tapOnReply(_:)), #selector(doneToolbar(_:)), #selector(tapOnAnswer(_:))])
        return cell
    }
}

// MARK: - UITableViewDelegate -
extension TRFeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = cellDataArray[indexPath.row].data.index
        if !feedArray[index].videoUrl.isBlank {
            playVideo(index)
        }
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
        //self.questionArray[textField.tag].value = textField.text!
    }
}

// MARK: - UITextViewDelegate -
extension TRFeedViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .darkGray {
            textView.text = nil
            textView.textColor = UIColor.white
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let indexPath = IndexPath(row: textView.tag, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if let index = textView.layer.value(forKey: "IndexVal") as? Int {
            feedArray[index].description = textView.text
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = messageString
            textView.textColor = .darkGray
        }
    }
}


// MARK: - PromptViewDelegate -
extension TRFeedViewController: PromptViewDelegate {
    func didActionOnPromptButton(_ tag: Int) {
        //Core.push(self, storyboard: Constants.Storyboard.trivia, storyboardId: "TRFeedViewController")
    }
}
