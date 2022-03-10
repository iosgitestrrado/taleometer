//
//  AudioViewCell.swift
//  TaleOMeter
//
//  Created by Durgesh on 22/02/22.
//

import UIKit

class AudioViewCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configureCell(_ titleStr: String, isNonStop: Bool, isFavourite: Bool, row: Int, selectedIndex: Int, target: Any, selectors: [Selector]) {
        self.isSelected = row == selectedIndex
        if let image = self.imageView {
            image.cornerRadius = image.frame.size.height / 2.0
        }
        self.playButton.isHidden = isNonStop
        self.favButton.isHidden = isNonStop
        if let titleLbl = self.titleLabel {
            if self.isSelected {
                let soundWave = Core.getImageString("wave")
                let titleAttText = NSMutableAttributedString(string: "\(titleStr)  ")
                titleAttText.append(soundWave)
                titleLbl.attributedText = titleAttText
                titleLbl.textColor = UIColor(displayP3Red: 213.0 / 255.0, green: 40.0 / 255.0, blue: 54.0 / 255.0, alpha: 1.0)
            } else {
                titleLbl.text = titleStr
                titleLbl.textColor = .white
            }
        }
        if !isNonStop {
            self.playButton.tag = row
            self.playButton.isSelected = self.isSelected
            self.playButton.addTarget(target, action: selectors[0], for: .touchUpInside)
            self.favButton.addTarget(target, action: selectors[1], for: .touchUpInside)
            if isFavourite {
                self.favButton.isSelected = isFavourite
            }
        }
    }
}
