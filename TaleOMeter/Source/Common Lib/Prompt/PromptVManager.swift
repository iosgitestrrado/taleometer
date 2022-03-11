//
//  PromptVManager.swift
//  TaleOMeter
//
//  Created by Durgesh on 18/02/22.
//  Copyright © 2022 Durgesh. All rights reserved.
//

import UIKit

class PromptVManager: NSObject {
    
    /*
     *  Dynamic Prompt screen
     *  Set prompt properties as per requirement
     */
    static func present(_ controller: UIViewController, verifyTitle: String = "Successfull", verifyMessage: String = "", imageName: String = "verified", isAudioView: Bool = false, isQuestion: Bool = false, isUserStory: Bool = false, audioImage: UIImage = defaultImage, closeBtnHide: Bool = false) {
        if let myobject = UIStoryboard(name: Constants.Storyboard.other, bundle: nil).instantiateViewController(withIdentifier: "PromptViewController") as? PromptViewController {
            myobject.delegate = controller as? PromptViewDelegate
            if isAudioView {
                myobject.songTitle = verifyTitle
                myobject.nextSongTitle = verifyMessage
            }
            myobject.isAudioPrompt = isAudioView
            myobject.isCloseBtnHide = closeBtnHide
            controller.navigationController?.present(myobject, animated: true, completion: {
                myobject.audioPromptView.isHidden = !isAudioView
                myobject.verifyPromptView.isHidden = !isUserStory
                myobject.answerPromptView.isHidden = !isQuestion
                if isAudioView {
                    myobject.audioImageView.image = audioImage
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
