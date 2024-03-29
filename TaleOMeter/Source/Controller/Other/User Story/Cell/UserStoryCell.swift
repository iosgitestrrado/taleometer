//
//  UserStoryCell.swift
//  TaleOMeter
//
//  Created by Durgesh on 23/02/22.
//

import UIKit

/*
 * Create user story every cell item
 * Cell Item Title
 * Cell Identifier
 * Cell Validation message
 * Cell Height
 */
public enum UserStoryCellItem: Equatable {
    case name
    case storyAbout
    case lifeMoment
    case sharePeople
    case incident
    case anythingElse
    case terms
    case submitButton

    var title: String {
        switch self {
        case .name:
            return "Name"
        case .storyAbout:
            return "Who is this story about?"
        case .lifeMoment:
            return "What's the life moment or story that you want to share with us? (e.g. wedding, 12th std math exam, fractured my leg)"
        case .sharePeople:
            return "Who where the people that were there when this happened, preferably with names."
        case .incident:
            return "Now when you think about that incident, how does it make you feel?"
        case .anythingElse:
            return "Anything else that you would like to share about incident? (e.g.: why this is important to you?, what was the impact of this incident?...)"
        default:
            return ""
        }
    }
    
    var titleTamil: String {
        switch self {
        case .name:
            return "பெயர்"
        case .storyAbout:
            return "இந்தக் கதை யாரைப் பற்றியது?"
        case .lifeMoment:
            return "நீங்கள் எங்களுடன் பகிர்ந்து கொள்ள விரும்பும் வாழ்க்கை தருணம் அல்லது கதை என்ன? (எ.கா. திருமணம், 12வது வகுப்பு கணிதத் தேர்வு, என் காலில் எலும்பு முறிவு)"
        case .sharePeople:
            return "இது நடந்தபோது அங்கு இருந்தவர்கள் யார், முன்னுரிமை பெயர்களுடன்."
        case .incident:
            return "இப்போது அந்தச் சம்பவத்தை நினைக்கும் போது, அது உங்களுக்கு எப்படித் தோன்றுகிறது?"
        case .anythingElse:
            return "சம்பவத்தைப் பற்றி வேறு ஏதாவது பகிர்ந்து கொள்ள விரும்புகிறீர்களா? (எ.கா: இது உங்களுக்கு ஏன் முக்கியமானது?, இந்த சம்பவத்தின் தாக்கம் என்ன?...)"
        default:
            return ""
        }
    }
    
    var cellIdentifier: String {
        switch self {
        case .name:
            return "textFieldCell"
        case .storyAbout:
            return "radioCell"
        case .lifeMoment:
            return "textViewCell"
        case .sharePeople:
            return "textViewCell"
        case .incident:
            return "textViewCell"
        case .anythingElse:
            return "textViewCell"
        case .terms:
            return "termsCell"
        case .submitButton:
            return "buttonCell"
        }
    }
    
    var errorMessge: String {
        switch self {
        case .name:
            return "Please enter your name"
        case .storyAbout:
            return "Please select radio button for 'Who is this story about?'"
        case .lifeMoment:
            return "Please share life moment of your story"
        case .sharePeople:
            return "Please enter people name who's with you when your story happened"
        case .incident:
            return "Please enter incident of your story"
        case .anythingElse:
            return "Please enter anything about incident of story"
        case .terms:
            return ""
        case .submitButton:
            return ""
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .name:
            return 83.0
        case .storyAbout:
            return 63.0
        case .lifeMoment:
            return 170.0
        case .sharePeople:
            return 170.0
        case .incident:
            return 170.0
        case .anythingElse:
            return 170.0
        case .terms:
            return 30.0
        case .submitButton:
            return 50.0
        }
    }
}

class UserStoryCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var optionBtn: UIButton!
    @IBOutlet weak var optionBtnn: UIButton!
    @IBOutlet weak var termsBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!

    @IBOutlet weak var option1Btn: UIButton!
    @IBOutlet weak var option2Btn: UIButton!
    @IBOutlet weak var option1Lbl: UILabel!
    @IBOutlet weak var option2Lbl: UILabel!
    @IBOutlet weak var radioStackView: UIStackView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var radioButton: UIButton!
    @IBOutlet weak var radioLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    private struct collectionCellData {
        var title = String()
        var isSelected = false
    }
    
    private var optionsData = [collectionCellData]()
    private var collectionRow = -1

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configuration(_ viewTitle: String, cellData: UserStoryModel, tamilTermsString: String, row: Int, target: Any, selectors: [Selector], options: [String] = [String](), options_tamil: [String] = [String]()) {
        
        // Selector: 0 - Terms and Condition, 1 - Submit button, 2 - Done tool bar, 3 - Next Tool bar, 4 - Option button
        
        if let titleLbl = self.titleLabel {
            titleLbl.text = viewTitle == "English" ? cellData.Title : cellData.Title_tamil
//            if viewTitle != "English" {
//                titleLbl.text = cellData.titleTamil
//            }
        }
        
        if cellData.TypeT.lowercased() == "choice", cellData.Options.count > 0, let optBtn = self.optionBtn, let optBtnn = self.optionBtnn {
            optBtn.tag = row
            optBtn.addTarget(target, action: selectors[4], for: .touchUpInside)
            optBtn.setTitle(viewTitle == "English" ? cellData.Value : cellData.Value_Tamil, for: .normal) //
            
            optBtnn.tag = row
            optBtnn.addTarget(target, action: selectors[4], for: .touchUpInside)
            optBtnn.setTitle("", for: .normal)
        }
        
//        if viewTitle != "English" {
//            if let opt1Lbl = self.option1Lbl {
//                opt1Lbl.text = "நானே"
//            }
//            if let opt2Lbl = self.option2Lbl {
//                opt2Lbl.text = "வேறு யாரோ"
//            }
//        }
        
        if let btn1 = self.termsBtn {
            btn1.tag = row
            btn1.addTarget(target, action: selectors[0], for: .touchUpInside)
            if viewTitle != "English" {
                //cell.option1Btn.titleLabel?.attributedText = NSAttributedString("எங்கள் விதிமுறைகள் மற்றும் நிபந்தனைகளைப் படிக்கவும்")
                let attString = NSMutableAttributedString(string: tamilTermsString)
                let fontBlue = [ NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 116.0 / 255.0, green: 117.0 / 255.0, blue: 182.0 / 255.0, alpha: 1.0) ]
                let fontRed = [ NSAttributedString.Key.foregroundColor:  UIColor(displayP3Red: 232.0 / 255.0, green: 56.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0) ]
                let rangeTitle1 = NSRange(location: 0, length: 65)
                let rangeTitle2 = NSRange(location: 33, length: 32)
                attString.addAttributes(fontBlue, range: rangeTitle1)
                attString.addAttributes(fontRed, range: rangeTitle2)
                if #available(iOS 15, *) {
                    btn1.setAttributedTitle(attString, for: .normal)
                } else {
                    // Fallback on earlier versions
                    btn1.setAttributedTitle(attString, for: .normal)
                }
            }
        }
        
        if let btn1 = self.submitBtn {
            btn1.tag = row
            btn1.addTarget(target, action: selectors[1], for: .touchUpInside)
        }
       
        if let textView = self.textView {
            textView.tag = row

            var doneString = "Done"
            if viewTitle != "English" {
                doneString = "முடிந்தது"
            }

            var nextString = "Next"
            if viewTitle != "English" {
                nextString = "அடுத்தது"
            }
            textView.addInputAccessoryView(cellData.IsLast ? doneString : nextString, target: target, selector: cellData.IsLast ? selectors[2] : selectors[3], tag: row)
            textView.delegate = target as? UITextViewDelegate
        }
        
        if self.collectionView != nil {
            collectionRow = row
            if viewTitle == "English" {
                for i in 0..<options.count {
                    self.optionsData.append(collectionCellData(title: options[i], isSelected: i == 0))
                }
            } else {
                for i in 0..<options_tamil.count {
                    self.optionsData.append(collectionCellData(title: options_tamil[i], isSelected: i == 0))
                }
            }
            self.collectionView.reloadData()
        }
    }
    
    func configuration1(_ viewTitle: String, cellData: UserStoryCellItem, tamilTermsString: String, section: Int, row: Int, target: Any, selectors: [Selector], optionButton1: inout UIButton, optionButton2: inout UIButton) {
        if let titleLbl = self.titleLabel {
            titleLbl.text = cellData.title
            if viewTitle != "English" {
                titleLbl.text = cellData.titleTamil
            }
        }

        if viewTitle != "English" {
            if let opt1Lbl = self.option1Lbl {
                opt1Lbl.text = "நானே"
            }
            if let opt2Lbl = self.option2Lbl {
                opt2Lbl.text = "வேறு யாரோ"
            }
        }
        if let btn1 = self.option1Btn {
            if cellData == .storyAbout {
                optionButton1 = btn1
            }
            btn1.tag = section
            btn1.addTarget(target, action: selectors[0], for: .touchUpInside)
            if viewTitle != "English" && section == 6 {
                //cell.option1Btn.titleLabel?.attributedText = NSAttributedString("எங்கள் விதிமுறைகள் மற்றும் நிபந்தனைகளைப் படிக்கவும்")
                let attString = NSMutableAttributedString(string: tamilTermsString)
                let fontBlue = [ NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 116.0 / 255.0, green: 117.0 / 255.0, blue: 182.0 / 255.0, alpha: 1.0) ]
                let fontRed = [ NSAttributedString.Key.foregroundColor:  UIColor(displayP3Red: 232.0 / 255.0, green: 56.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0) ]
                let rangeTitle1 = NSRange(location: 0, length: 65)
                let rangeTitle2 = NSRange(location: 33, length: 32)
                attString.addAttributes(fontBlue, range: rangeTitle1)
                attString.addAttributes(fontRed, range: rangeTitle2)
                if #available(iOS 15, *) {
                    btn1.setAttributedTitle(attString, for: .normal)
                } else {
                    // Fallback on earlier versions
                    btn1.setAttributedTitle(attString, for: .normal)
                }
            }
        }
        if let btn2 = self.option2Btn {
            if cellData == .storyAbout {
                optionButton2 = btn2
            }
            btn2.tag = section
            btn2.addTarget(target, action: selectors[1], for: .touchUpInside)
        }
        if let textField = self.textField {
            textField.tag = section
            textField.returnKeyType = .next
            textField.delegate = target as? UITextFieldDelegate
        }
        if let textView = self.textView {
            textView.tag = section
            if section == 5 {
                var doneString = "Done"
                if viewTitle != "English" {
                    doneString = "முடிந்தது"
                }
                textView.addInputAccessoryView(doneString, target: target, selector: selectors[2], tag: section)
            } else {
                var nextString = "Next"
                if viewTitle != "English" {
                    nextString = "அடுத்தது"
                }
                textView.addInputAccessoryView(nextString, target: target, selector: selectors[3], tag: section)
            }
            textView.delegate = target as? UITextViewDelegate
        }
//        if self.collectionView != nil {
//            self.optionsData = options
//            self.collectionView.reloadData()
//        }
    }
    
    @objc func tapOnRadio(_ sender: UIButton) {
        for i in 0..<optionsData.count {
            optionsData[i].isSelected = false
        }
        optionsData[sender.tag].isSelected = true
        self.collectionView.reloadData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateRadioButton"), object: nil, userInfo: ["rowIndexInt": collectionRow, "selectedAnswer": optionsData[sender.tag].title])
    }
}

extension UserStoryCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return optionsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "radioCollectionCell", for: indexPath) as? RadioCollectionViewCell {
            cell.configure(optionsData[indexPath.row].title, isSelected: optionsData[indexPath.row].isSelected, target: self, selector: #selector(tapOnRadio(_ : )), row: indexPath.row)
            return cell
        }
        return UICollectionViewCell()
    }
}
