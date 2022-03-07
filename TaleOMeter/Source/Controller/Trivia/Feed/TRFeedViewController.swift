//
//  TRFeedViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 03/03/22.
//

import UIKit

/*private enum CellIdentifier: Equatable {
 case image
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
}*/

class TRFeedViewController: UIViewController {
    
    // MARK: - Weak Properties -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tblBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Private Properties -
    private let viewMoreText = "--------------------  View More  --------------------"
    private struct CommentModel {
        var image = String()
        var name = String()
        var comment = String()
        var time = String()
        var isExpanded = false
        var replies = [CommentModel]()
    }
    private struct FeedModel {
        var image = String()
        var videoUrl = String()
        var question = String()
        var answer = String()
        var isExpanded = false
        var comments = [CommentModel]()
        var time = String()
    }

    private var feedArray: [FeedModel] = {
        var feedArr = [FeedModel]()
        
        var commentArr = [CommentModel]()
        commentArr.append(CommentModel(image: "person", name: "You", comment: "Tenali Raman", time: "1 hours ago", replies: [CommentModel]()))
        
        var replyArr = [CommentModel]()
        replyArr.append(CommentModel(image: "person", name: "Amblin", comment: "Wrong Answer", time: "1 hour ago", replies: [CommentModel]()))
        replyArr.append(CommentModel(image: "person", name: "You", comment: "Right Answer is Tenali Raman", time: "50 minutes ago", replies: [CommentModel]()))
        replyArr.append(CommentModel(image: "person", name: "John Doe", comment: "Thank you!", time: "48 minutes ago", replies: [CommentModel]()))
        replyArr.append(CommentModel(image: "person", name: "Amblin", comment: "Welcome!", time: "30 minutes ago", replies: [CommentModel]()))
        replyArr.append(CommentModel(image: "person", name: "John Doe", comment: "Yes! I have checked right answer is Tenali Raman", time: "20 minutes ago", replies: [CommentModel]()))
        replyArr.append(CommentModel(image: "person", name: "You", comment: "Where you have check this answer?", time: "10 minutes ago", replies: [CommentModel]()))
        replyArr.append(CommentModel(image: "person", name: "You", comment: "I checked this answer online!", time: "2 minutes ago", replies: [CommentModel]()))
        commentArr.append(CommentModel(image: "person", name: "John Doe", comment: "Birbal", time: "2 hours ago", replies: replyArr))
        
        replyArr = [CommentModel]()
        replyArr.append(CommentModel(image: "person", name: "Amblin", comment: "Wrong Answer! Please try again", time: "10 minutes ago", replies: [CommentModel]()))
        replyArr.append(CommentModel(image: "person", name: "You", comment: "Right Answer is Tenali Raman", time: "7 minutes ago", replies: [CommentModel]()))
        replyArr.append(CommentModel(image: "person", name: "Joseph", comment: "Thank you!", time: "2 minutes ago", replies: [CommentModel]()))
        commentArr.append(CommentModel(image: "person", name: "Joseph", comment: "Dora", time: "3 hours ago", replies: replyArr))
        
        commentArr.append(CommentModel(image: "person", name: "Benpham", comment: "Tenali Raman", time: "3 hours 10 minutes ago", replies: [CommentModel]()))
        commentArr.append(CommentModel(image: "person", name: "Steven", comment: "Tenali Raman", time: "3 hours 30 minutes ago", replies: [CommentModel]()))
        commentArr.append(CommentModel(image: "person", name: "Brent French", comment: "Tenali Raman", time: "4 hours ago", replies: [CommentModel]()))
        
        feedArr.append(FeedModel(image: "tenali", videoUrl: "", question: "Who is the Character in this Image?", answer: "Tenali Raman", comments: commentArr, time: ""))
        return feedArr
    }()
        
    private struct Data {
        var image = String()
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
    
    private var cellDataArray: [CellItem] = [CellItem]()
    private var cellArray: [String] = ["imageCell", "postedCell", "moreRpCell", "replyCell", "replyCell", "replyCell", "viewMoreCell", "postCell"]
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        self.hideKeyboard()
        setTableViewCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true, titleInLeft: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHideNotification), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    private func setTableViewCells() {
        cellDataArray = [CellItem]()
        for index in 0..<feedArray.count {
            let feed = feedArray[index]
            cellDataArray.append(CellItem(cellId: FeedCellIdentifier.image, data: Data(image: feed.image, title: feed.question, description: "", time: "")))
            if feed.comments.count > 0 {
                for comIndex in 0..<feed.comments.count {
                    let comment = feed.comments[comIndex]
                    if !feed.isExpanded && comIndex == 3 {
                        cellDataArray.append(CellItem(cellId: FeedCellIdentifier.viewMore, data: Data(image: "", title: viewMoreText, description: "", time: "", index: index)))
                        break
                    }
                    cellDataArray.append(CellItem(cellId: FeedCellIdentifier.comment, data: Data(image: comment.image, title: comment.name, description: comment.comment, time: comment.time)))
                    if comment.replies.count > 0 {
                        for repIndex in 0..<comment.replies.count {
                            let reply = comment.replies[repIndex]
                            if !comment.isExpanded && repIndex == 0 {
                                cellDataArray.append(CellItem(cellId: FeedCellIdentifier.moreReply, data: Data(image: "", title: "View previous \(comment.replies.count - 1) replies", description: "", time: "", index: index, commentIndex: comIndex)))
                                cellDataArray.append(CellItem(cellId: FeedCellIdentifier.reply, data: Data(image: reply.image, title: reply.name, description: reply.comment, time: reply.time)))
                                break
                            }
                            cellDataArray.append(CellItem(cellId: FeedCellIdentifier.reply, data: Data(image: reply.image, title: reply.name, description: reply.comment, time: reply.time)))
                        }
                    }
                }
                
            }
            cellDataArray.append(CellItem(cellId: FeedCellIdentifier.post, data: Data(image: "person", title: "", description: "", time: "")))
        }
        self.tableView.reloadSections(IndexSet(integer: 0), with: .bottom)
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
    @objc private func keyboardDidHideNotification(notification: Notification) {
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
        cell.configureCell(cellData.image, title: cellData.title, description: cellData.description, time: cellData.time, cellId: cellDataArray[indexPath.row].cellId, row: indexPath.row)
        
        if let viewMoreBtn = cell.viewMore {
            viewMoreBtn.tag = cellData.index
            viewMoreBtn.addTarget(self, action: #selector(tapOnViewMore(_:)), for: .touchUpInside)
        }
        if let viewPrevReplyBtn = cell.viewPrevReply {
            viewPrevReplyBtn.tag = cellData.index
            viewPrevReplyBtn.layer.setValue(cellData.commentIndex, forKey: "CommentIndex")
            viewPrevReplyBtn.addTarget(self, action: #selector(tapOnViewPrevReply(_:)), for: .touchUpInside)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate -
extension TRFeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        guard let cell = tableView.cellForRow(at: indexPath) as? FeedCellView else {
//            return 0
//        }
        return UITableView.automaticDimension
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
        //self.questionArray[textField.tag].value = textField.text!
    }
}
