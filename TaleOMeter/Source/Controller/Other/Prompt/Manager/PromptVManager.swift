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
    static func present(_ controller: UIViewController, verifyTitle: String = "Successful", verifyMessage: String = "", verifyImage: UIImage? = nil, queImage: String = "", ansImage: String = "", isAudioView: Bool = false, isQuestion: Bool = false, isUserStory: Bool = false, audioImage: String = "", closeBtnHide: Bool = false, isFavourite: Bool = false, isLogoutView: Bool = false) {
        if let myobject = UIStoryboard(name: Constants.Storyboard.other, bundle: nil).instantiateViewController(withIdentifier: "PromptViewController") as? PromptViewController {

            myobject.delegate = controller as? PromptViewDelegate
            if isAudioView {
                myobject.songTitle = verifyTitle
                myobject.nextSongTitle = verifyMessage
            }
            myobject.currentController = controller
            myobject.isAudioPrompt = isAudioView
            myobject.isCloseBtnHide = closeBtnHide || isLogoutView
            myobject.isFromFavourite = isFavourite
            myobject.isFromLogout = isLogoutView
            controller.navigationController?.present(myobject, animated: true, completion: {
                myobject.audioPromptView.isHidden = !isAudioView
                myobject.verifyPromptView.isHidden = !isUserStory
                myobject.answerPromptView.isHidden = !isQuestion
                myobject.expandButton.isHidden = !isQuestion
                myobject.logoutPromptView.isHidden = !isLogoutView
                myobject.imageExpandView.isHidden = true
                
                if isAudioView {
                    myobject.audioImageView.sd_setImage(with: URL(string: audioImage), placeholderImage: defaultImage, options: [], context: nil)
                    myobject.audioImageView.cornerRadius = myobject.audioImageView.frame.size.height / 2.0
                } else if isQuestion {
                    myobject.questionImage.sd_setImage(with: URL(string: queImage), placeholderImage: defaultImage, options: [], context: nil)
                    myobject.answerTitle.text = verifyMessage
                    //myobject.answerMessage.text = verifyMessage
                    myobject.answerMessage.text = "Answer:"
                    if !ansImage.isBlank {
                        myobject.answerImageView.isHidden = false
                        myobject.answerImage.sd_setImage(with: URL(string: ansImage), placeholderImage: defaultImage, options: [], context: nil)
                        myobject.answerTitle.isHidden = true
                    } else {
                        myobject.answerImageView.isHidden = true
                        myobject.answerMessage.isHidden = false
                    }
                    myobject.questionImage.isHidden = true
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
