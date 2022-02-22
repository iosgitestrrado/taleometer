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
    static func present(_ controller: UIViewController, isAudioView: Bool = true, verifyMessage: String = "") {
        if let myobject = UIStoryboard(name: Storyboard.dashboard, bundle: nil).instantiateViewController(withIdentifier: "PromptViewController") as? PromptViewController {
            
            myobject.delegate = controller as? PromptViewDelegate
            if (isAudioView) {
                myobject.songTitle = "Learn Brightly"
                myobject.nextSongTitle = "Track To Relax"
            }
            controller.navigationController?.present(myobject, animated: true, completion: {
                myobject.audioPromptView.isHidden = !isAudioView
                myobject.verifyPromptView.isHidden = isAudioView
                if (isAudioView) {
                    myobject.audioImageView.cornerRadius = myobject.audioImageView.frame.size.height / 2.0
                } else {
                    myobject.messageLabelV.text = verifyMessage
                }
            })
        }
    }
}
