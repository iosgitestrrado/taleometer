//
//  FeedCellView.swift
//  TaleOMeter
//
//  Created by Durgesh on 05/03/22.
//

import UIKit
import SDWebImage

struct FeedCellIdentifier {
    static let image = "imageCell"
    static let video = "videoCell"
    static let comment = "commentCell"
    static let moreReply = "moreRpCell"
    static let reply = "replyCell"
    static let viewMore = "viewMoreCell"
    static let post = "postCell"
    static let question = "questionCell"
    static let questionVideo = "questionVideoCell"
    static let replyPost = "replyPostCell"
}

struct CellData {
    var imageUrl = String()
    var profilePic: UIImage?
    var title = String()
    var description = String()
    var time = String()
    var index = Int()
    var commentIndex = Int()
    var replyIndex = Int()
}

class FeedCellView: UITableViewCell {
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var subTitleXConstraint: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descText: UITextView!
   // @IBOutlet weak var mainVStackView: UIStackView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var videoButton: UIButton!

//    @IBOutlet weak var postStackView: UIStackView!
//    @IBOutlet weak var pSProfileImage: UIImageView!
//    @IBOutlet weak var pSNameLabel: UILabel!
//    @IBOutlet weak var pSCommentLabel: UILabel!
//    @IBOutlet weak var pSHourLabel: UILabel!
//    @IBOutlet weak var pSReplyLabel: UILabel!

//    @IBOutlet weak var replyStackView: UIStackView!
//    @IBOutlet weak var repProfileImage: UIImageView!
//    @IBOutlet weak var repNameLabel: UILabel!
//    @IBOutlet weak var repCommentLabel: UILabel!
//    @IBOutlet weak var repHourLabel: UILabel!
//    @IBOutlet weak var repReplyLabel: UILabel!
    
    @IBOutlet weak var viewPrevReply: UIButton!
    @IBOutlet weak var viewMore: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var answerButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
//        if cellId == FeedCellIdentifier.image || cellId == FeedCellIdentifier.video || cellId == FeedCellIdentifier.question || cellId == FeedCellIdentifier.questionVideo {
        if let videoBtn = self.videoButton {
            videoBtn.layer.cornerRadius = 20
            videoBtn.layer.masksToBounds = true
            videoBtn.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        
        if let btmView = self.bottomView {
            btmView.layer.cornerRadius = 20
            btmView.layer.masksToBounds = true
            btmView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
            
        if let mView = self.mainView {
            mView.layer.cornerRadius = 20
            mView.layer.masksToBounds = true
            mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    
    func configureCell(_ cellData: CellData, cellId: String, messageString: String, videoUrl: String, row: Int, target: Any, selectors: [Selector]) {
        if let cImage = self.coverImage {
            if cellId == FeedCellIdentifier.post || cellId == FeedCellIdentifier.replyPost {
                cImage.image = cellData.profilePic ?? (cellId == FeedCellIdentifier.post || cellId == FeedCellIdentifier.replyPost ? Login.defaultProfileImage : defaultImage)
            } else {
                cImage.sd_setImage(with: URL(string: cellData.imageUrl), placeholderImage: Constants.loaderImage, options: []) { imgg, error, typrr, url in
                    if error != nil {
                        cImage.image = cellId == FeedCellIdentifier.post || cellId == FeedCellIdentifier.replyPost ? Login.defaultProfileImage : defaultImage
                    }
                }
            }
            if cellId == FeedCellIdentifier.question {
                cImage.layer.cornerRadius = 20
                cImage.layer.masksToBounds = true
                cImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
        }
        if !cellData.title.isBlank, let titl = self.titleLabel {
            titl.text = cellData.title
        }
        if !cellData.description.isBlank, let desc = self.descLabel {
            desc.text = cellData.description
        }
        if !cellData.description.isBlank, let subTitl = self.subTitle {
            subTitl.text = cellData.description
        }
        if let descText = self.descText {
            descText.delegate = target as? UITextViewDelegate
            addToolBar(descText, messageString: messageString, target: target, selector: selectors[4])
            descText.tag = row
            descText.layer.setValue(cellData.index, forKey: "IndexVal")
            descText.setError()
        }
        
        if let textFld = self.textField {
            textFld.delegate = target as? UITextFieldDelegate
            textFld.tag = row
            textFld.layer.setValue(cellData.index, forKey: "IndexVal")
            textFld.setError()
        }
        if let timeLbl = self.timeLabel/*, let date = time*/ {
            timeLbl.text = cellData.time//Core.soMuchTimeAgo(date.timeIntervalSince1970)
        }
        
        if !cellData.title.isBlank, let viewPR = self.viewPrevReply {
            viewPR.setTitle(cellData.title, for: .normal)
        }
        
        if cellId == FeedCellIdentifier.post {
            self.contentView.layer.cornerRadius = 20
            self.contentView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
       
        if let postBtn = self.postButton {
            postBtn.tag = cellData.index
            postBtn.layer.setValue(row, forKey: "RowIndex")
            postBtn.layer.setValue(cellData.commentIndex, forKey: "CommentIndex")
            postBtn.addTarget(target, action: selectors[0], for: .touchUpInside)
        }
        if let viewMoreBtn = self.viewMore {
            viewMoreBtn.tag = cellData.index
            viewMoreBtn.addTarget(target, action: selectors[1], for: .touchUpInside)
        }
        if let viewPrevReplyBtn = self.viewPrevReply {
            viewPrevReplyBtn.tag = cellData.index
            viewPrevReplyBtn.layer.setValue(cellData.commentIndex, forKey: "CommentIndex")
            viewPrevReplyBtn.addTarget(target, action: selectors[2], for: .touchUpInside)
        }
        
        if let replyBtn = self.replyButton {
            replyBtn.isHidden = cellId == FeedCellIdentifier.reply
            replyBtn.tag = row
            replyBtn.layer.setValue(cellData.index, forKey: "CellIndex")
            replyBtn.layer.setValue(cellData.commentIndex, forKey: "CommentIndex")
            replyBtn.layer.setValue(cellData.replyIndex, forKey: "ReplyIndex")
            replyBtn.addTarget(target, action: selectors[3], for: .touchUpInside)
        }
        if let answerBtn = self.answerButton {
            answerBtn.tag = cellData.index
            answerBtn.layer.setValue(row, forKey: "RowIndex")
            answerBtn.addTarget(target, action: selectors[5], for: .touchUpInside)
        }
        if let videoBtn = self.videoButton {
            if !videoUrl.isBlank {
                videoBtn.tag = cellData.index
                videoBtn.layer.setValue(row, forKey: "RowIndex")
                videoBtn.addTarget(target, action: selectors[6], for: .touchUpInside)
            }
            videoBtn.setBackgroundImage(UIImage(named: "acastro_180403_1777_youtube_0001") ?? defaultImage, for: .normal)
        }
    }
    
    // MARK: - Add toolbar on keyboard
    private func addToolBar(_ textView: UITextView, messageString: String, target: Any, selector: Selector) {
        textView.addInputAccessoryView("Done", target: target, selector: selector)
        textView.text = messageString
        textView.textColor = UIColor(displayP3Red: 84.0 / 255.0, green: 85.0 / 255.0, blue: 135.0 / 255.0, alpha: 1.0)
        
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
    }
}
