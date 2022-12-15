//
//  NotificationTableViewCell.swift
//  TaleOMeter
//
//  Created by Durgesh on 01/12/22.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    static let identifier = "notificationCell"
    
    @IBOutlet weak var imageVW: UIImageView!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ cellData: NotificationModel, target: Any, selector: Selector) {
        if imageVW != nil {
            imageVW.sd_setImage(with: URL(string: cellData.BannerUrl), placeholderImage: defaultImage, context: nil)
        }
        
        if descriptionLbl != nil {
            descriptionLbl.text = cellData.Content
        }
        
        if dateTimeLabel != nil {
            dateTimeLabel.text = cellData.Created_at
        }
        
        if closeButton != nil {
            closeButton.tag = cellData.Id
            closeButton.addTarget(target, action: selector, for: .touchUpInside)
        }
    }

}
