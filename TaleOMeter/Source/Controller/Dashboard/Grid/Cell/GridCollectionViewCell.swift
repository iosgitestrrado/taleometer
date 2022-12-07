//
//  GridCollectionViewCell.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit


class GridViewTableCell: UITableViewCell {
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imgBackView1: UIView!
    @IBOutlet weak var numberOfCountLbl1: UILabel!
    @IBOutlet weak var titleLabe1: UILabel!
    @IBOutlet weak var rowButton1: UIButton!
    @IBOutlet weak var highLightView1: UIView!
    @IBOutlet weak var highLightLbl1: UILabel!
    
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imgBackView2: UIView!
    @IBOutlet weak var numberOfCountLbl2: UILabel!
    @IBOutlet weak var titleLabe2: UILabel!
    @IBOutlet weak var rowButton2: UIButton!
    @IBOutlet weak var highLightView2: UIView!
    @IBOutlet weak var highLightLbl2: UILabel!
    
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imgBackView3: UIView!
    @IBOutlet weak var numberOfCountLbl3: UILabel!
    @IBOutlet weak var titleLabe3: UILabel!
    @IBOutlet weak var rowButton3: UIButton!
    @IBOutlet weak var highLightView3: UIView!
    @IBOutlet weak var highLightLbl3: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        if imageView1 != nil {
            imageView1.layer.cornerRadius = imageView1.frame.size.height / 2.0
        }
        if imageView2 != nil {
            imageView2.layer.cornerRadius = imageView1.frame.size.height / 2.0
        }
        if imageView3 != nil {
            imageView3.layer.cornerRadius = imageView1.frame.size.height / 2.0
        }
        if imgBackView1 != nil {
            imgBackView1.layer.cornerRadius = imgBackView1.frame.size.height / 2.0
        }
        if imgBackView2 != nil {
            imgBackView2.layer.cornerRadius = imgBackView2.frame.size.height / 2.0
        }
        if imgBackView3 != nil {
            imgBackView3.layer.cornerRadius = imgBackView3.frame.size.height / 2.0
        }
        if highLightView1 != nil {
            highLightView1.layer.masksToBounds = true
            highLightView1.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            highLightView1.layer.cornerRadius = highLightView1.frame.size.width / 2.0
        }
        if highLightView2 != nil {
            highLightView2.layer.masksToBounds = true
            highLightView2.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            highLightView2.layer.cornerRadius = highLightView1.frame.size.width / 2.0
        }
        if highLightView3 != nil {
            highLightView3.layer.masksToBounds = true
            highLightView3.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            highLightView3.layer.cornerRadius = highLightView1.frame.size.width / 2.0
        }
    }
}

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
        imageView.sd_setImage(with: URL(string: cellData.ImageUrl), placeholderImage: Constants.loaderImage, options: []) { [self] imgg, error, typrr, url in
            if error != nil {
                imageView.image = defaultImage
            }
        }
//        imageView.frame = CGRect(x: 0.0, y: 0.0, width: gridWidth * 2, height: gridHeight - titleViewHeight)
//        titleView.frame = CGRect(x: 0.0, y: gridHeight - titleViewHeight, width: (gridWidth * 2) + 10.0, height: titleViewHeight)
        self.titleLabel.text = cellData.Title
        let countString = NSMutableAttributedString(string: "\(cellData.Post_count)\nnew")
        let rangeTitle1 = NSRange(location: 0, length: cellData.Post_count.description.utf8.count)
        let rangeTitle2 = NSRange(location: cellData.Post_count.description.utf8.count, length: 4)

        countString.addAttributes(font15, range: rangeTitle1)
        countString.addAttributes(font8, range: rangeTitle2)
        countLable.attributedText = countString//"\(cellData.Post_count)"
        countLable.isHidden = cellData.Post_count == 0
    }
    
    func configureCellCat(_ cellData: TriviaCategory, gridWidth: CGFloat, gridHeight: CGFloat, titleViewHeight: CGFloat, row: Int) {
        imageView.sd_setImage(with: URL(string: cellData.Category_image_url), placeholderImage: Constants.loaderImage, options: []) { [self] imgg, error, typrr, url in
            if error != nil {
                imageView.image = defaultImage
            }
        }
       // imageView.frame = CGRect(x: 0.0, y: 0.0, width: gridWidth, height: gridHeight - (titleViewHeight))
        //titleView.frame = CGRect(x: 0.0, y: gridHeight - (titleViewHeight + 50.0), width: gridWidth, height: (titleViewHeight + 50.0))
       //titleLabel.frame = CGRect(x: 15.0, y: 0.0, width: gridWidth - 15.0, height: (titleViewHeight + 50.0))
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
