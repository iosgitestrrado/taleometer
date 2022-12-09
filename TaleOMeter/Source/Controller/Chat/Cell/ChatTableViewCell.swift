//
//  ChatTableViewCell.swift
//  TaleOMeter
//
//  Created by Durgesh on 02/12/22.
//

import UIKit
import SDWebImage

class ChatTableViewCell: UITableViewCell {
    
    static let leftIdentifier = "leftCell"
    static let rightIdentifier = "rightCell"
    static let dateIdentifier = "dateCell"
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var imageViewV: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(_ cellData: ChatData) {
        if titleLabel != nil {
            titleLabel.isHidden = cellData.Chat_type.lowercased() == "chat"
            titleLabel.text = cellData.Chat_type
        }
        if dateLabel != nil {
            dateLabel.text = cellData.Chat_time
        }
        if imageViewV != nil {
            imageViewV.isHidden = cellData.Image.isEmpty
            if !cellData.Image.isEmpty {
                imageViewV.sd_setImage(with: URL(string: cellData.Image), placeholderImage: defaultImage, context: nil)
            }
        }
        if messageLabel != nil {
            messageLabel.text = cellData.Message
            messageLabel.sizeToFit()
        }
        if mainStackView != nil {
            mainStackView.layer.masksToBounds = true
            mainStackView.layer.maskedCorners = cellData.Align.lowercased() == "right" ? [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner] : [.layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            mainStackView.layer.cornerRadius = 10.0
            mainStackView.sizeToFit()
        }
        self.sizeToFit()
        self.contentView.sizeToFit()
    }
}
