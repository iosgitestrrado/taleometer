//
//  FeedCellView.swift
//  TaleOMeter
//
//  Created by Durgesh on 05/03/22.
//

import UIKit
import SDWebImage
import AVFoundation

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
    var videoThumbnail = String()
    var title = String()
    var description = String()
    var time = String()
    var index = Int()
    var commentIndex = Int()
    var replyIndex = Int()
}
//var videoThumnailImages = [UIImage?]()

class FeedCellView: UITableViewCell {
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var subTitleXConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoBtnBottomConst: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descText: UITextView!
    @IBOutlet weak var mainVStackView: UIStackView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var videoButton1: UIButton!
    
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var songTitle: MarqueeLabel!
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!


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
        
        if let mainSView = self.mainVStackView {
            mainSView.layer.cornerRadius = 20
            mainSView.layer.masksToBounds = true
            mainSView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
            
        if let mView = self.mainView {
            mView.layer.cornerRadius = 20
            mView.layer.masksToBounds = true
            mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    
//    func configureLeaderboard(with cellData: LeaderboardModel) {
//        if self.coverImage != nil {
//            self.coverImage.sd_setImage(with: URL(string: cellData.Image), placeholderImage: defaultImage)
//        }
//        if self.titleLabel != nil {
//            self.titleLabel.text = cellData.Title
//        }
//    }
    
    func configureCell(_ cellData: CellData, cellId: String, messageString: String, videoUrl: String, row: Int, target: Any, selectors: [Selector], questionType: String) {
//        if videoThumnailImages.count <= cellData.index {
//            videoThumnailImages.append(nil)
//        }
        if audioView != nil {
            audioView.isHidden = questionType.lowercased() != "audio"
        }
        if videoBtnBottomConst != nil {
            videoBtnBottomConst.constant = 0.0
            if questionType.lowercased() == "audio" {
                videoBtnBottomConst.constant = 60.0
            }
        }
        if let cImage = self.coverImage {
            if cellId == FeedCellIdentifier.post || cellId == FeedCellIdentifier.replyPost {
                cImage.image = cellData.profilePic ?? (cellId == FeedCellIdentifier.post || cellId == FeedCellIdentifier.replyPost ? Login.defaultProfileImage : defaultImage)
            } else {
                if let image = profilePic, (cellData.title == "You" && (cellId == FeedCellIdentifier.comment || cellId == FeedCellIdentifier.reply)) {
                    cImage.image = image
                } else {
                    cImage.sd_setImage(with: URL(string: cellData.imageUrl), placeholderImage: Constants.loaderImageBig, options: []) { imgg, error, typrr, url in
                        if error != nil {
                            cImage.image = cellId == FeedCellIdentifier.post || cellId == FeedCellIdentifier.replyPost ? Login.defaultProfileImage : defaultImage
                        }
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
            //replyBtn.isHidden = cellId == FeedCellIdentifier.reply
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
        if let imgBtn = self.imageButton {
            imgBtn.tag = cellData.index
            imgBtn.addTarget(target, action: selectors[7], for: .touchUpInside)
        }
        
        if let audioPlayBtn = self.playButton {
            audioPlayBtn.tag = cellData.index
            audioPlayBtn.layer.setValue(row, forKey: "RowIndex")
            audioPlayBtn.addTarget(target, action: selectors[8], for: .touchUpInside)
        }
        
        if let videoBtn = self.videoButton, let videoBtn1 = self.videoButton1 {
            if !videoUrl.isBlank {
                videoBtn.tag = cellData.index
                videoBtn.layer.setValue(row, forKey: "RowIndex")
                videoBtn.addTarget(target, action: selectors[6], for: .touchUpInside)
                videoBtn.isUserInteractionEnabled = questionType.lowercased() != "audio"
                videoBtn1.tag = cellData.index
                videoBtn1.layer.setValue(row, forKey: "RowIndex")
                videoBtn1.addTarget(target, action: selectors[6], for: .touchUpInside)
            }
            //if !cellData.videoThumbnail.isBlank {
//            if let thumImg = videoThumnailImages[cellData.index] {
//                videoBtn.setBackgroundImage(thumImg, for: .normal)
//            } else {
            videoBtn1.isHidden = false
            if questionType.lowercased() == "audio" {
//                videoBtn1.isHidden = false
                videoBtn.sd_setBackgroundImage(with: URL(string: cellData.videoThumbnail), for: .normal, placeholderImage: UIImage(named: "bannerimage"), options: []) { imgg, error, typrr, url in
                    if error != nil {
                        videoBtn.setBackgroundImage(UIImage(named: "bannerimage") ?? defaultImage, for: .normal)
                    }
                }
            } else {
                videoBtn.sd_setBackgroundImage(with: URL(string: cellData.videoThumbnail), for: .normal, placeholderImage: Constants.loaderImageBig, options: []) { imgg, error, typrr, url in
                    if error != nil {
                        videoBtn.setBackgroundImage(UIImage(named: "acastro_180403_1777_youtube_0001") ?? defaultImage, for: .normal)
                    }
                }
            }
        }
    }
    
    private func getThumbnailImage(forUrl url: URL, completion: @escaping(UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let asset: AVAsset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            do {
                let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
                completion(UIImage(cgImage: thumbnailImage))
            } catch let error {
                print(error)
                completion(nil)
            }
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
