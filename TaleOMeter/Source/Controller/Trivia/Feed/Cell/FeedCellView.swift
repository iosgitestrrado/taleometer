//
//  FeedCellView.swift
//  TaleOMeter
//
//  Created by Durgesh on 05/03/22.
//

import UIKit

struct FeedCellIdentifier {
    static let image = "imageCell"
    static let comment = "commentCell"
    static let moreReply = "moreRpCell"
    static let reply = "replyCell"
    static let viewMore = "viewMoreCell"
    static let post = "postCell"
    static let replyPost = "replyPostCell"
}

class FeedCellView: UITableViewCell {
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descText: UITextView!
    @IBOutlet weak var mainVStackView: UIStackView!
    @IBOutlet weak var mainView: UIView!

    @IBOutlet weak var postStackView: UIStackView!
    @IBOutlet weak var pSProfileImage: UIImageView!
    @IBOutlet weak var pSNameLabel: UILabel!
    @IBOutlet weak var pSCommentLabel: UILabel!
    @IBOutlet weak var pSHourLabel: UILabel!
    @IBOutlet weak var pSReplyLabel: UILabel!

    @IBOutlet weak var replyStackView: UIStackView!
    @IBOutlet weak var repProfileImage: UIImageView!
    @IBOutlet weak var repNameLabel: UILabel!
    @IBOutlet weak var repCommentLabel: UILabel!
    @IBOutlet weak var repHourLabel: UILabel!
    @IBOutlet weak var repReplyLabel: UILabel!
    
    @IBOutlet weak var viewPrevReply: UIButton!
    @IBOutlet weak var viewMore: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var answerButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configureCell(_ image: String, title: String, description: String, time: Date?, cellId: String, messageString: String, row: Int, cellIndex: Int, commentIndex: Int, replyIndex: Int, target: Any, selectors: [Selector]) {
        if !image.isBlank, let cImage = self.coverImage {
            cImage.image = UIImage(named: image)
        }
        if !title.isBlank, let titl = self.titleLabel {
            titl.text = title
        }
        if !description.isBlank, let desc = self.descLabel {
            desc.text = description
        }
        if let descText = self.descText {
            descText.delegate = target as? UITextViewDelegate
            addToolBar(descText, messageString: messageString, target: target, selector: selectors[4])
            descText.tag = row
            descText.layer.setValue(cellIndex, forKey: "IndexVal")
        }
        if let timeLbl = self.timeLabel, let date = time {
            timeLbl.text = Core.soMuchTimeAgo(date.timeIntervalSince1970)
        }
        
        if !title.isBlank, let viewPR = self.viewPrevReply {
            viewPR.setTitle(title, for: .normal)
        }
        
        if cellId == FeedCellIdentifier.image {
            self.coverImage.layer.cornerRadius = 20
            self.coverImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.mainView.layer.cornerRadius = 20
            self.mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        
        if cellId == FeedCellIdentifier.post {
            self.contentView.layer.cornerRadius = 20
            self.contentView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
       
        if let postBtn = self.postButton {
            postBtn.tag = cellIndex
            postBtn.layer.setValue(row, forKey: "RowIndex")
            postBtn.layer.setValue(commentIndex, forKey: "CommentIndex")
            postBtn.addTarget(target, action: selectors[0], for: .touchUpInside)
        }
        if let viewMoreBtn = self.viewMore {
            viewMoreBtn.tag = cellIndex
            viewMoreBtn.addTarget(target, action: selectors[1], for: .touchUpInside)
        }
        if let viewPrevReplyBtn = self.viewPrevReply {
            viewPrevReplyBtn.tag = cellIndex
            viewPrevReplyBtn.layer.setValue(commentIndex, forKey: "CommentIndex")
            viewPrevReplyBtn.addTarget(target, action: selectors[2], for: .touchUpInside)
        }
        if let replyBtn = self.replyButton {
            replyBtn.tag = row
            replyBtn.layer.setValue(cellIndex, forKey: "CellIndex")
            replyBtn.layer.setValue(commentIndex, forKey: "CommentIndex")
            replyBtn.layer.setValue(replyIndex, forKey: "ReplyIndex")
            replyBtn.addTarget(target, action: selectors[3], for: .touchUpInside)
        }
        if let answerBtn = self.answerButton {
            answerBtn.tag = cellIndex
            answerBtn.addTarget(target, action: selectors[5], for: .touchUpInside)
        }
    }
    
    // MARK: - Add toolbar on keyboard
    private func addToolBar(_ textView: UITextView, messageString: String, target: Any, selector: Selector) {
        textView.addInputAccessoryView("Done", target: target, selector: selector)
        textView.text = messageString
        textView.textColor = .darkGray
        
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
    }
}
