//
//  FAQTableViewCell.swift
//  TaleOMeter
//
//  Created by Durgesh on 02/12/22.
//

import UIKit
import SoundWave

class FAQTableViewCell: UITableViewCell {

    static let sectionIdentifier = "sectionCell"
    static let audioIdentifier = "audioCell"
    static let contentIdentifier = "contentCell"

    @IBOutlet weak var lable1Lbl: UILabel!
    @IBOutlet weak var lable2Lbl: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var visualizationWave: AudioVisualizationView! {
        didSet {
            visualizationWave.meteringLevelBarWidth = 1.0
            visualizationWave.meteringLevelBarInterItem = 1.0
            visualizationWave.audioVisualizationTimeInterval = 0.30
            visualizationWave.gradientStartColor = .white
            visualizationWave.gradientEndColor = .red
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureSection(_ cellData: FAQModel, isExpanded: Bool = false) {
        if lable1Lbl != nil {
            lable1Lbl.text = "\(cellData.Question_eng) / \(cellData.Question_tamil)"
        }
        if lable2Lbl != nil {
            lable2Lbl.text = isExpanded ? "-" : "+"
        }
        if mainStackView != nil {
            mainStackView.backgroundColor = UIColor(displayP3Red: 37.0 / 255.0, green: 37.0 / 255.0, blue: 61.0 / 255.0, alpha: 1.0)
            if isExpanded {
                mainStackView.backgroundColor = UIColor(displayP3Red: 74.0 / 255.0, green: 73.0 / 255.0, blue: 113.0 / 255.0, alpha: 1.0)
            }
        }
    }
    
    func configureContent(_ cellData: FAQModel) {
        if lable1Lbl != nil {
            lable1Lbl.text = cellData.Answer_eng
        }
        if lable2Lbl != nil {
            lable2Lbl.text = cellData.Answer_tamil
        }
    }
}
