//
//  ChatTableViewCell.swift
//  TaleOMeter
//
//  Created by Durgesh on 02/12/22.
//

import UIKit

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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
