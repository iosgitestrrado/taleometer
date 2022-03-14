//
//  PostCellView.swift
//  TaleOMeter
//
//  Created by Durgesh on 04/03/22.
//

import UIKit

class PostCellView: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var answerText: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        videoButton.layer.cornerRadius = 20
        videoButton.layer.masksToBounds = true
        videoButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        bottomView.layer.cornerRadius = 20
        bottomView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        selectionStyle = .none
    }
    
    func configureCell(_ title: String, value: String, coverImage: UIImage, videoUrl: String, row: Int, target: Any, selectors: [Selector]) {
        self.titleLabel.text = title
        self.answerText.tag = row
        self.answerText.delegate = target as? UITextFieldDelegate
        self.answerText.text = value
        self.answerText.returnKeyType = .done//isLastrow ? .done : .next
        
        if let btn = self.submitButton {
            btn.tag = row
            btn.addTarget(target, action: selectors[0], for: .touchUpInside)
        }
        
        if let videoBtn = self.videoButton {
            if !videoUrl.isBlank {
                videoBtn.tag = row
                videoBtn.addTarget(target, action: selectors[1], for: .touchUpInside)
            }
            videoBtn.setBackgroundImage(coverImage, for: .normal)
        }
    }
}
