//
//  PromptVManager.swift
//  TaleOMeter
//
//  Created by Durgesh on 18/02/22.
//

import UIKit

class PromptVManager: NSObject {
    
    /*
     *  Dynamic Prompt screen
     *  Set prompt properties as per requirement
     */
    static func present(_ controller: UIViewController, isAudioView: Bool = true, verifyTitle: String = "Successfull", verifyMessage: String = "", imageName: String = "verified", isQuestion: Bool = false) {
        if let myobject = UIStoryboard(name: Storyboard.other, bundle: nil).instantiateViewController(withIdentifier: "PromptViewController") as? PromptViewController {
            myobject.delegate = controller as? PromptViewDelegate
            if (isAudioView) {
                myobject.songTitle = "Learn Brightly"
                myobject.nextSongTitle = "Track To Relax"
            }
            myobject.isAudioPrompt = isAudioView
            controller.navigationController?.present(myobject, animated: true, completion: {
                myobject.audioPromptView.isHidden = !isAudioView && isQuestion
                myobject.verifyPromptView.isHidden = isAudioView && isQuestion
                myobject.answerPromptView.isHidden = !isAudioView && !isQuestion
                if isAudioView {
                    myobject.audioImageView.cornerRadius = myobject.audioImageView.frame.size.height / 2.0
                } else if isQuestion {
                    myobject.answerImage.image = UIImage(named: imageName)
                    myobject.answerTitle.text = verifyTitle
                    myobject.answerMessage.text = verifyMessage
                } else {
                    myobject.titleLabelV.text = verifyTitle
                    myobject.messageLabelV.text = verifyMessage
                    myobject.verifyImage.image = UIImage(named: imageName)
                }
            })
        }
    }
}
