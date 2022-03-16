//
//  TRFeedViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 03/03/22.
//

import UIKit
import AVKit
import SwiftyJSON

class TRFeedViewController: UIViewController {
    
    // MARK: - Weak Properties -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tblBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Public Properties
    var categoryId = -1
        
    // MARK: - Private Properties -
    private let viewMoreText = "--------------------  View More  --------------------"
    private struct Data {
        var image = UIImage()
        var title = String()
        var description = String()
        var time = String()
        var index = Int()
        var commentIndex = Int()
        var replyIndex = Int()
    }
    private struct CellItem {
        var cellId = String()
        var data = Data()
    }
    private var postData = [TriviaPost]()
    private var cellDataArray: [CellItem] = [CellItem]()
    private let messageString = "Write A Comment..."
    private let personImage = UIImage(named: "person")!
    
    private var footerView = UIView()
    private var morePage = true
    private var pageNumber = 1
    private var showNoData = 0

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "NoDataTableViewCell")
        self.initFooterView()
        self.hideKeyboard()
        self.getTriviaPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true, titleInLeft: false, backImage: true, backImageColor: .red)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Initialize table footer view
    func initFooterView() {
        footerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: Double(self.view.frame.size.width), height: 40.0))
        let actind = UIActivityIndicatorView(style: .medium)
        actind.tag = 10
        actind.frame = CGRect(x: (self.view.frame.size.width / 2.0) - 20.0, y: 5.0, width: 40.0, height: 40.0)
        actind.hidesWhenStopped = true
        footerView.addSubview(actind)
        footerView.isHidden = false
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
    
    @objc private func tapOnAnswer(_ sender: UIButton) {
        if !Reachability.isConnectedToNetwork() {
            Toast.show()
            return
        }
        if let rowIndex = sender.layer.value(forKey: "RowIndex") as? Int {
            if cellDataArray[rowIndex].cellId == FeedCellIdentifier.question {
                if postData[sender.tag].Value.isBlank {
                    if let textFlield = postData[sender.tag].TextField {
                        Validator.showRequiredError(textFlield)
                    }
                    return
                }
                Core.ShowProgress(self, detailLbl: "Submitting Answer...")
                TriviaClient.submitAnswer(SubmitAnswerRequest(post_id: postData[sender.tag].Post_id, answer: postData[sender.tag].Value)) { [self] status in
                    Core.HideProgress(self)
                    if let st = status, st {
                        self.getComments(postId: postData[sender.tag].Post_id, postIndex: sender.tag)
                    }
                }
            } else {
                Core.ShowProgress(self, detailLbl: "")
                TriviaClient.getAnswers(PostIdRequest(post_id: postData[sender.tag].Post_id)) { [self] response in
                    if let data = response {
                        PromptVManager.present(self, verifyTitle: data.Answer_text, verifyMessage: postData[sender.tag].Question, image: postData[sender.tag].Question_media, ansImage: data.Answer_text.isBlank ? data.Answer_image : nil, isQuestion: true, closeBtnHide: true)
                    }
                    Core.HideProgress(self)
                }
            }
        }
    }
    
    // MARK: Tap on view more comment
    @objc private func tapOnViewMore(_ sender: UIButton) {
        if !postData[sender.tag].IsExpanded {
            postData[sender.tag].IsExpanded = true
            self.setTableViewCells()
        }
    }
    
    // MARK: Tap on view previous reply
    @objc private func tapOnViewPrevReply(_ sender: UIButton) {
        if let comIndex = sender.layer.value(forKey: "CommentIndex") as? Int,  !postData[sender.tag].Comments[comIndex].IsExpanded {
            postData[sender.tag].Comments[comIndex].IsExpanded = true
            self.setTableViewCells()
        }
    }
    
    // MARK: Tap on post button
    @objc private func tapOnPost(_ sender: UIButton) {
        if !Reachability.isConnectedToNetwork() {
            Toast.show()
            return
        }
        if let rowIndex = sender.layer.value(forKey: "RowIndex") as? Int {
            if cellDataArray[rowIndex].cellId == FeedCellIdentifier.post {
                if postData[sender.tag].Value.isBlank {
                    if let textView = postData[sender.tag].CommTextView {
                        Validator.showRequiredErrorTextView(textView)
                    }
                    return
                }
                // Add new comment
                addComment(postData[sender.tag].Post_id, commentId: nil, comment: postData[sender.tag].Value) { [self] status in
                    if let st = status, st {
                        self.getComments(postId: postData[sender.tag].Post_id, postIndex: sender.tag)
                    }
                }
            } else if cellDataArray[rowIndex].cellId == FeedCellIdentifier.replyPost, let commIndex = sender.layer.value(forKey: "CommentIndex") as? Int {
                if postData[sender.tag].Value.isBlank {
                    if let textView = postData[sender.tag].RepTextView {
                        Validator.showRequiredErrorTextView(textView)
                    }
                    return
                }
                // Add new reply in comment
                addComment(postData[sender.tag].Post_id, commentId: postData[sender.tag].Comments[commIndex].Comment_id, comment: postData[sender.tag].Value) { [self] status in
                    if let st = status, st {
                        self.getComments(true, postId: postData[sender.tag].Post_id, postIndex: sender.tag)
                    }
                }
            }
        }
    }
    
    // MARK: Tap on reply Button
    @objc private func tapOnReply(_ sender: UIButton) {
        if let cellIndex = sender.layer.value(forKey: "CellIndex") as? Int, let commentIndex = sender.layer.value(forKey: "CommentIndex") as? Int, let replyIndex = sender.layer.value(forKey: "ReplyIndex") as? Int {
            if cellDataArray.contains(where: { cell in cell.cellId == FeedCellIdentifier.replyPost}) {
                cellDataArray.removeAll(where: { cell in cell.cellId == FeedCellIdentifier.replyPost })
            }
            cellDataArray.insert(CellItem(cellId: FeedCellIdentifier.replyPost, data: Data(image: personImage, title: "", description: "", time: "", index: cellIndex, commentIndex: commentIndex, replyIndex: replyIndex)), at: sender.tag + 1)
            self.tableView.reloadData()
        }
    }
    
    // MARK: Tap on video Button
    @objc private func tapOnVideo(_ sender: UIButton) {
        if let videoURL = URL(string: postData[sender.tag].QuestionVideoURL) {
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            playerViewController.showsPlaybackControls = true
            self.present(playerViewController, animated: true) {
                playerViewController.player?.play()
            }
        } else {
            Toast.show("No video found!")
        }
    }
    
    // MARK: - Click on done button of keyborad toolbar
    @objc private func doneToolbar(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
    
    // MARK: - Play a video in video controller
    private func playVideo(_ row: Int) {
        
    }
}

extension TRFeedViewController {
    // MARK: - Get trivia posts
    private func getTriviaPosts(_ replyExpanded: Bool = false, showProgress: Bool = true) {
        if !Reachability.isConnectedToNetwork() {
            Toast.show()
            return
        }
        if showProgress {
            Core.ShowProgress(self, detailLbl: "")
        }
        if categoryId >= 0 {
            // MARK: - Get trivia posts by category
            TriviaClient.getCategoryPosts(pageNumber, req: TriviaCategoryRequest(category: categoryId)) { [self] response in
                if let data = response {
                    postData = postData + data
                    morePage = data.count > 0
                }
                showNoData = 1
                setTableViewCells(replyExpanded)
                tableView.tableFooterView = UIView()
                if showProgress {
                    Core.HideProgress(self)
                }
            }
        } else {
            // MARK: - Get trivia daily posts
            TriviaClient.getTriviaDailyPost(pageNumber) { [self] response in
                if let data = response {
                    postData = postData + data
                    morePage = data.count > 0
                }
                showNoData = 1
                setTableViewCells(replyExpanded)
                tableView.tableFooterView = UIView()
                if showProgress {
                    Core.HideProgress(self)
                }
            }
        }
    }
    
    // MARK: - Get comments using post id
    private func getComments(_ replyExpanded: Bool = false, postId: Int, postIndex: Int) {
        if !Reachability.isConnectedToNetwork() {
            Toast.show()
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        TriviaClient.getComments(PostIdRequest(post_id: postId)) { [self] response in
            if let data = response {
                postData[postIndex].User_answer_status = true
                postData[postIndex].Comments = data
            }
            setTableViewCells(replyExpanded)
            Core.HideProgress(self)
        }
    }
    
    // MARK: - Add Commnet -
    private func addComment(_ postId: Int, commentId: Int?, comment: String, completion: @escaping(Bool?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            TriviaClient.addComments(AddCommentRequest(post_id: postId, comment_id: commentId, comment: comment)) { status in
                completion(status)
            }
        }
    }
    
    // MARK: - Set cell for tableview
    private func setTableViewCells(_ replyExpanded: Bool = false) {
        cellDataArray = [CellItem]()
        
        // each for index of post
        for index in 0..<postData.count {
            
            /// get post model
            let feed = postData[index]
            
            if feed.User_answer_status {
                /// Add Image and question title cell with view answer
                cellDataArray.append(CellItem(cellId: FeedCellIdentifier.image, data: Data(image: feed.Question_media, title: feed.Question, description: "", time: "", index: index)))
            } else {
                /// Add Image and question title cell with submit answer
                cellDataArray.append(CellItem(cellId: FeedCellIdentifier.question, data: Data(image: feed.Question_media, title: feed.Question, description: "", time: "", index: index)))
            }
            
            /// Check comment
            if feed.Comments.count > 0 {
                
                /// comment for each
                for comIndex in 0..<feed.Comments.count {
                    
                    /// Get comment model
                    var comment = feed.Comments[comIndex]
                    
                    /// Check is explanded or not
                    if !feed.IsExpanded && comIndex == 3 {
                        /// Add view more text cell
                        cellDataArray.append(CellItem(cellId: FeedCellIdentifier.viewMore, data: Data(image: personImage, title: viewMoreText, description: "", time: "", index: index, commentIndex: comIndex)))
                        break
                    }
                    
                    /// Add comment cell
                    cellDataArray.append(CellItem(cellId: FeedCellIdentifier.comment, data: Data(image: personImage, title: comment.User_name, description: comment.Comment, time: comment.Time_ago, index: index, commentIndex: comIndex)))
                    
                    /// Check reply exists
                    if comment.Reply.count > 0 {
                        
                        /// Reply for each
                        for repIndex in 0..<comment.Reply.count {
                            
                            /// Get reply model
                            let reply = comment.Reply[repIndex]
                            
                            /// If reply by user
                            if replyExpanded {
                                comment.IsExpanded = true
                            }
                            
                            /// Check Comment expanded
                            if !comment.IsExpanded && repIndex == 0 && comment.Reply.count > 1 {
                                
                                /// Add view previous reply cell
                                cellDataArray.append(CellItem(cellId: FeedCellIdentifier.moreReply, data: Data(image: personImage, title: "View previous \(comment.Reply_count - 1) replies", description: "", time: "", index: index, commentIndex: comIndex)))
                                
                                /// Add reply cell
                                cellDataArray.append(CellItem(cellId: FeedCellIdentifier.reply, data: Data(image: personImage, title: reply.User_name, description: reply.Comment, time: reply.Time_ago, index: index, commentIndex: comIndex, replyIndex: repIndex)))
                                break
                            }
                            
                            /// Add reply cell
                            cellDataArray.append(CellItem(cellId: FeedCellIdentifier.reply, data: Data(image: personImage, title: reply.User_name, description: reply.Comment, time: reply.Time_ago, index: index, commentIndex: comIndex, replyIndex: repIndex)))
                        }
                    }
                }
            }
            
            if feed.User_answer_status {
                /// Add post comment cell
                cellDataArray.append(CellItem(cellId: FeedCellIdentifier.post, data: Data(image: personImage, title: "", description: "", time: "", index: index)))
            }
        }
        self.tableView.reloadData()
        //self.tableView.reloadSections(IndexSet(integer: 0), with: .bottom)
    }
}

// MARK: - UITableViewDataSource -
extension TRFeedViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDataArray.count > 0 ? self.cellDataArray.count : showNoData
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.cellDataArray.count <= 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataTableViewCell", for: indexPath) as? NoDataTableViewCell else { return UITableViewCell() }
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellDataArray[indexPath.row].cellId, for: indexPath) as? FeedCellView else { return UITableViewCell() }
        let cellData = cellDataArray[indexPath.row].data
        cell.configureCell(cellData.image, title: cellData.title,
                           description: cellData.description, time: cellData.time,
                           cellId: cellDataArray[indexPath.row].cellId,
                           messageString: messageString, videoUrl: postData[cellData.index].QuestionVideoURL, row: indexPath.row,
                           cellIndex: cellData.index, commentIndex: cellData.commentIndex,
                           replyIndex: cellData.replyIndex, target: self,
                           selectors: [#selector(tapOnPost(_:)), #selector(tapOnViewMore(_:)),  #selector(tapOnViewPrevReply(_:)),  #selector(tapOnReply(_:)), #selector(doneToolbar(_:)), #selector(tapOnAnswer(_:)), #selector(tapOnVideo(_:))])
        if cellDataArray[indexPath.row].cellId == FeedCellIdentifier.question, let textField = cell.textField {
            postData[cellData.index].TextField = textField
        }
        if cellDataArray[indexPath.row].cellId == FeedCellIdentifier.post, let textView = cell.descText {
            postData[cellData.index].CommTextView = textView
        }
        if cellDataArray[indexPath.row].cellId == FeedCellIdentifier.replyPost, let textView = cell.descText {
            postData[cellData.index].RepTextView = textView
        }
        return cell
    }
}

// MARK: - UITableViewDelegate -
extension TRFeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellDataArray.count <= 0 ? (showNoData == 1 ? 30 : 0) : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cellDataArray.count > 5 && indexPath.row == cellDataArray.count - 1 && self.morePage {
            //last cell load more
            pageNumber += 1
            tableView.tableFooterView = footerView
            if let indicator = footerView.viewWithTag(10) as? UIActivityIndicatorView {
                indicator.startAnimating()
            }
            DispatchQueue.global(qos: .background).async { DispatchQueue.main.async { self.getTriviaPosts(showProgress: false) } }
        }
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
        textView.setError()
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
            postData[index].Value = textView.text
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty /*|| textView.text == messageString*/ {
            textView.text = messageString
            textView.textColor = .darkGray
            //Validator.showRequiredErrorTextView(textView)
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
        textField.setError()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text!.isBlank {
            //Validator.showRequiredError(textField)
            return
        }
        if let index = textField.layer.value(forKey: "IndexVal") as? Int {
            self.postData[index].Value = textField.text!
        }
    }
}

// MARK: - PromptViewDelegate -
extension TRFeedViewController: PromptViewDelegate {
    func didActionOnPromptButton(_ tag: Int) {
        //Core.push(self, storyboard: Constants.Storyboard.trivia, storyboardId: "TRFeedViewController")
    }
}
