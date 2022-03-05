//
//  QuestionCellView.swift
//  TaleOMeter
//
//  Created by Durgesh on 04/03/22.
//

import UIKit

class QuestionCellView: UITableViewCell {
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var answerText: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        coverImage.layer.cornerRadius = 20
        coverImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        bottomView.layer.cornerRadius = 20
        bottomView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        selectionStyle = .none
    }
    
    func configureCell(_ title: String, value: String, coverImage: String, videoUrl: String, controller: UIViewController, row: Int, isLastrow: Bool) {
        self.titleLabel.text = title
        self.coverImage.image = UIImage(named: coverImage)
        self.answerText.tag = row
        self.answerText.delegate = controller as? UITextFieldDelegate
        self.answerText.text = value
        self.answerText.returnKeyType = .done//isLastrow ? .done : .next
    }
}
