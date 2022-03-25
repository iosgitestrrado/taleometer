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
    private let font15 = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0, weight: .heavy) ]
    private let font8 = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0) ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if titleView != nil {
            titleView.layer.cornerRadius = 20
            titleView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
        if imageView != nil {
            imageView.layer.cornerRadius = 20
            imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    
    func configureCell(_ cellData: TriviaDaily, gridWidth: CGFloat, gridHeight: CGFloat, titleViewHeight: CGFloat, row: Int) {
        imageView.sd_setImage(with: URL(string: cellData.ImageUrl), placeholderImage: defaultImage, options: [], context: nil)
        imageView.frame = CGRect(x: 0.0, y: 0.0, width: gridWidth * 2, height: gridHeight - titleViewHeight)
        titleView.frame = CGRect(x: 0.0, y: gridHeight - titleViewHeight, width: (gridWidth * 2) + 10.0, height: titleViewHeight)
        self.titleLabel.text = cellData.Title
        let countString = NSMutableAttributedString(string: "\(cellData.Post_count)\nnew")
        let rangeTitle1 = NSRange(location: 0, length: cellData.Post_count.description.utf8.count)
        let rangeTitle2 = NSRange(location: cellData.Post_count.description.utf8.count, length: cellData.Post_count.description.utf8.count + 3)

        countString.addAttributes(font15, range: rangeTitle1)
        countString.addAttributes(font8, range: rangeTitle2)
        countLable.attributedText = countString//"\(cellData.Post_count)"
        countLable.isHidden = cellData.Post_count == 0
    }
    
    func configureCellCat(_ cellData: TriviaCategory, gridWidth: CGFloat, gridHeight: CGFloat, titleViewHeight: CGFloat, row: Int) {
        imageView.sd_setImage(with: URL(string: cellData.Category_image_url), placeholderImage: defaultImage, options: [], context: nil)
        imageView.frame = CGRect(x: 0.0, y: 0.0, width: gridWidth, height: gridHeight - titleViewHeight)
        titleView.frame = CGRect(x: 0.0, y: gridHeight - titleViewHeight, width: gridWidth, height: titleViewHeight)
        titleLabel.frame = CGRect(x: 15.0, y: 0.0, width: gridWidth - 15.0, height: titleViewHeight)
        self.titleLabel.text = cellData.Category_name
//        let countString = NSMutableAttributedString(string: "\(count)\nNew Qus")
//        countString.addAttributes(font15, range: rangeTitle1)
//        countString.addAttributes(font8, range: rangeTitle2)
        countLable.text = "\(cellData.Post_count)"//countString
        countLable.isHidden = cellData.Post_count == 0
    }
}

class GridCollecViewCell: UICollectionViewCell {
    // MARK: - Weak Properties -
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = imageView.frame.size.height / 2.0
    }
    
}
