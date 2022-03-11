//
//  PromptViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit

// MARK: - Protocol used for sending data back -
protocol PromptViewDelegate: AnyObject {
    func didActionOnPromptButton(_ tag: Int)
}

class PromptViewController: UIViewController {

    // MARK: - Weak Property -
    @IBOutlet weak var audioPromptView: UIView!
    @IBOutlet weak var songTitleLbl: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var audioImageView: UIImageView!
    @IBOutlet weak var remainSecondLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!

    @IBOutlet weak var verifyPromptView: UIView!
    @IBOutlet weak var verifyImage: UIImageView!
    @IBOutlet weak var titleLabelV: UILabel!
    @IBOutlet weak var messageLabelV: UILabel!
    
    @IBOutlet weak var answerPromptView: UIView!
    @IBOutlet weak var answerImage: UIImageView!
    @IBOutlet weak var answerTitle: UILabel!
    @IBOutlet weak var answerMessage: UILabel!
    
    // Making this a weak variable, so that it won't create a strong reference cycle
    weak var delegate: PromptViewDelegate? = nil
    
    // MARK: - Public Properties -
    var songTitle = ""
    var nextSongTitle = ""
    var isAudioPrompt: Bool = false
    var isCloseBtnHide: Bool = false

    // MARK: - Private Properties -
    private var timer = Timer()
    private var remainingSecond = 5
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        closeButton.isHidden = isCloseBtnHide
        if isAudioPrompt {
            //You Just listened to "Track To Relax"
            let titleString = NSMutableAttributedString(string: "You Just listened to \n\"\(songTitle)\"")

            let font16 = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0) ]
            let font22 = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22.0) ]
            let rangeTitle1 = NSRange(location: 0, length: 21)
            let rangeTitle2 = NSRange(location: 21, length: songTitle.utf8.count + 2) // 10 is title character length
            
            titleString.addAttributes(font16, range: rangeTitle1)
            titleString.addAttributes(font22, range: rangeTitle2)
            self.songTitleLbl.attributedText = titleString
            
            setRemainTitle()
            
            timer = Timer(timeInterval: 1.0, target: self, selector: #selector(PromptViewController.updateTimer), userInfo: nil, repeats: true)
            RunLoop.main.add(self.timer, forMode: .default)
            timer.fire()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setRemainTitle() {
        //Learn Brightly Up Next In 5s
        let remainString = NSMutableAttributedString(string: "\(nextSongTitle) \n Up Next In \n \(remainingSecond)s")

        let font16 = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0) ]
        let font48 = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 48.0) ]
        let rangeRemain1 = NSRange(location: 0, length: nextSongTitle.utf8.count + 14)// 10 is title character length
        let rangeRemain2 = NSRange(location: remainString.length - 2, length: 2) // 9 is total of title character length + 10
        
        remainString.addAttributes(font16, range: rangeRemain1)
        remainString.addAttributes(font48, range: rangeRemain2)
        self.remainSecondLabel.attributedText = remainString
    }
    
    @objc func updateTimer() {
        if remainingSecond < 0 {
            timer.invalidate()
            self.delegate?.didActionOnPromptButton(2)
            self.dismiss(animated: true, completion: nil)
        } else {
            setRemainTitle()
        }
        remainingSecond -= 1
    }
    
    // 0 - tag
    @IBAction func tapOnAddToFav(_ sender: Any) {
        self.delegate?.didActionOnPromptButton(0)
    }
    
    // 1 - tag
    @IBAction func tapOnOnceMore(_ sender: Any) {
        timer.invalidate()
        self.delegate?.didActionOnPromptButton(1)
        self.dismiss(animated: true, completion: nil)
    }
    
    // 2 - tag
    @IBAction func tapOnConfirm(_ sender: Any) {
        if timer.isValid {
            timer.invalidate()
        }
        if let delegate = delegate {
            delegate.didActionOnPromptButton(2)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapOnClose(_ sender: Any) {
        if timer.isValid {
            timer.invalidate()
        }
        if let delegate = delegate {
            delegate.didActionOnPromptButton(3)
        }
        self.dismiss(animated: true, completion: nil)
    }
}
