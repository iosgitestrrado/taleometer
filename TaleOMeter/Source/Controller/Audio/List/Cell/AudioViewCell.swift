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
    
    func configureCell(_ audioData: Audio, likesCount: Int, duration: Double, isFavourite: Bool, row: Int, selectedIndex: Int, target: Any, selectors: [Selector]) {
        self.isSelected = row == selectedIndex
        if let image = self.profileImage {
            image.sd_setImage(with: URL(string: audioData.ImageUrl), placeholderImage: defaultImage, options: [], context: nil)
            image.cornerRadius = image.frame.size.height / 2.0
        }
        if let subTitle = self.subTitleLabel {
            subTitle.text = "\(audioData.Favorites_count) Likes | \(AudioPlayManager.getHoursMinutesSecondsFromString(seconds: Double(audioData.Duration)))"
        }
        if let titleLbl = self.titleLabel {
            if self.isSelected {
                let soundWave = Core.getImageString("wave")
                let titleAttText = NSMutableAttributedString(string: "\(audioData.Title)  ")
                titleAttText.append(soundWave)
                titleLbl.attributedText = titleAttText
                titleLbl.textColor = UIColor(displayP3Red: 213.0 / 255.0, green: 40.0 / 255.0, blue: 54.0 / 255.0, alpha: 1.0)
            } else {
                titleLbl.text = audioData.Title
                titleLbl.textColor = .white
            }
        }
        self.playButton.tag = row
        self.playButton.isSelected = self.isSelected
        self.playButton.addTarget(target, action: selectors[0], for: .touchUpInside)
        self.favButton.tag = row
        self.favButton.addTarget(target, action: selectors[1], for: .touchUpInside)
        self.favButton.isSelected = audioData.Is_favorite
        if isFavourite {
            self.favButton.isSelected = isFavourite
        }
    }
}
