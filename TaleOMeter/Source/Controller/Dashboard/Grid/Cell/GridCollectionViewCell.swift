//
//  GridCollectionViewCell.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit

class GridCollectionViewCell: UICollectionViewCell {
    // MARK: - Weak Properties -
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLable: UILabel!
    @IBOutlet weak var titleView: UIView!
    
    // MARK: - Private Properties -
    private let font15 = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0) ]
    private let font8 = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 8.0) ]
    private let rangeTitle1 = NSRange(location: 0, length: 2)
    private let rangeTitle2 = NSRange(location: 2, length: 8)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if titleView != nil {
            titleView.layer.cornerRadius = 20
            titleView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }
    
    func configureCell(_ title: String, coverImage: String, count: Int, gridWidth: CGFloat, gridHeight: CGFloat, titleViewHeight: CGFloat, row: Int) {
        imageView.image = UIImage(named: coverImage)
        if row == 0 {
            imageView.frame = CGRect(x: 0.0, y: 0.0, width: gridWidth * 2, height: gridHeight - titleViewHeight)
            titleView.frame = CGRect(x: 0.0, y: gridHeight - titleViewHeight, width: gridWidth * 2, height: titleViewHeight)
        } else {
            imageView.frame = CGRect(x: 0.0, y: 0.0, width: gridWidth, height: gridHeight - titleViewHeight)
            titleView.frame = CGRect(x: 0.0, y: gridHeight - titleViewHeight, width: gridWidth, height: titleViewHeight)
            titleLabel.frame = CGRect(x: 15.0, y: 0.0, width: gridWidth - 15.0, height: titleViewHeight)
        }
        titleLabel.text = title
                
        let countString = NSMutableAttributedString(string: "\(count)\nNew Qus")
        countString.addAttributes(font15, range: rangeTitle1)
        countString.addAttributes(font8, range: rangeTitle2)
        countLable.text = "\(count)"//countString
    }
}
