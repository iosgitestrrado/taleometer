//
//  RadioCollectionViewCell.swift
//  TaleOMeter
//
//  Created by Eppancy on 30/09/22.
//

import UIKit

class RadioCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var radioButton: UIButton!
    @IBOutlet weak var radioTitleLbl: UILabel!
    
    func configure(_ title: String, isSelected: Bool, target: Any, selector: Selector, row: Int) {
        if radioTitleLbl != nil {
            self.radioTitleLbl.text = title
        }
        if radioButton != nil {
            radioButton.tag = row
            radioButton.isSelected = isSelected
            radioButton.addTarget(target, action: selector, for: .touchUpInside)
        }
    }
}
