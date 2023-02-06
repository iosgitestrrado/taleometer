//
//  LeaderBoardTableViewCell.swift
//  TaleOMeter
//
//  Created by Durgesh on 29/11/22.
//

import UIKit

class LeaderBoardTableViewCell: UITableViewCell {

    static let identifier = "leaderboardCell"
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ cellData: LeaderboardModel, row: Int) {
        if mainStackView != nil {
            mainStackView.backgroundColor = UIColor(displayP3Red: 37.0 / 255.0, green: 37.0 / 255.0, blue: 61.0 / 255.0, alpha: 1.0)
            mainStackView.borderColor = .white
            if row == 0 {
                mainStackView.borderColor = .clear
                mainStackView.backgroundColor = UIColor(displayP3Red: 240.0 / 255.0, green: 199.0 / 255.0, blue: 94.0 / 255.0, alpha: 1.0)
            } else if row == 1 {
                mainStackView.borderColor = .clear
                mainStackView.backgroundColor = UIColor(displayP3Red: 229.0 / 255.0, green: 230.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
            } else if row == 2 {
                mainStackView.borderColor = .clear
                mainStackView.backgroundColor = UIColor(displayP3Red: 237.0 / 255.0, green: 157.0 / 255.0, blue: 94.0 / 255.0, alpha: 1.0)
            }
            //1 - Yellow - 240, 199, 94
            //2 - Gray - 229, 230, 232
            //3 - Orange - 237, 157, 94
            // Default Blue - 37, 37, 61
        }
        if nameLabel != nil {
            nameLabel.text = cellData.Name
            nameLabel.textColor = .white
            if row == 0 || row == 1 || row == 2 {
                nameLabel.textColor = .black
            }
        }
        if scoreLabel != nil {
            scoreLabel.text = cellData.Points
            scoreLabel.textColor = .white
            if row == 0 || row == 1 || row == 2 {
                scoreLabel.textColor = .black
            }
        }
        if profileImage != nil {
            self.profileImage.sd_setImage(with: URL(string: cellData.Avatar), placeholderImage: Login.defaultProfileImage, context: nil)
        }
    }
}
