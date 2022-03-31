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
    static func present(_ controller: UIViewController, verifyTitle: String = "Successfull", verifyMessage: String = "", verifyImage: UIImage? = nil, queImage: String = "", ansImage: String = "", isAudioView: Bool = false, isQuestion: Bool = false, isUserStory: Bool = false, audioImage: String = "", closeBtnHide: Bool = false, isFavourite: Bool = false) {
        if let myobject = UIStoryboard(name: Constants.Storyboard.other, bundle: nil).instantiateViewController(withIdentifier: "PromptViewController") as? PromptViewController {

            myobject.delegate = controller as? PromptViewDelegate
            if isAudioView {
                myobject.songTitle = verifyTitle
                myobject.nextSongTitle = verifyMessage
            }
            myobject.currentController = controller
            myobject.isAudioPrompt = isAudioView
            myobject.isCloseBtnHide = closeBtnHide
            myobject.isFromFavourite = isFavourite
            controller.navigationController?.present(myobject, animated: true, completion: {
                myobject.audioPromptView.isHidden = !isAudioView
                myobject.verifyPromptView.isHidden = !isUserStory
                myobject.answerPromptView.isHidden = !isQuestion
                if isAudioView {
                    myobject.audioImageView.sd_setImage(with: URL(string: audioImage), placeholderImage: defaultImage, options: [], context: nil)
                    myobject.audioImageView.cornerRadius = myobject.audioImageView.frame.size.height / 2.0
                } else if isQuestion {
                    myobject.questionImage.sd_setImage(with: URL(string: queImage), placeholderImage: defaultImage, options: [], context: nil)
                    myobject.answerTitle.text = verifyTitle
                    if !ansImage.isBlank {
                        myobject.answerTitle.text = "Answer:"
                        myobject.answerImage.sd_setImage(with: URL(string: ansImage), placeholderImage: defaultImage, options: [], context: nil)
                    } else {
                        myobject.answerImage.isHidden = true
                    }
                    myobject.answerMessage.text = verifyMessage

                } else {
                    myobject.titleLabelV.text = verifyTitle
                    myobject.messageLabelV.text = verifyMessage
                    if let imageIs = verifyImage {
                        myobject.verifyImage.image = imageIs
                    } else {
                        myobject.verifyImage.image = UIImage(named: "verified")!
                    }
                }
            })
        }
    }
}
