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
    static func present(_ controller: UIViewController) {
        if let myobject = UIStoryboard(name: Storyboard.dashboard, bundle: nil).instantiateViewController(withIdentifier: "PromptViewController") as? PromptViewController {
            myobject.delegate = controller as? PromptViewDelegate
            myobject.songTitle = "Learn Brightly"
            myobject.nextSongTitle = "Track To Relax"
            controller.navigationController?.present(myobject, animated: true, completion: {
                myobject.audioImageView.cornerRadius = myobject.audioImageView.frame.size.height / 2.0
            })
        }
    }
}
