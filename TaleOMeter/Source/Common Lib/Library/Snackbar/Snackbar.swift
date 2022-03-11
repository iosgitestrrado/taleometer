//
//  Snackbar.swift
//  TaleOMeter
//
//  Created by Durgesh on 15/02/22.
//

import Foundation
import TTGSnackbar

class Snackbar {
    static let snackbar = TTGSnackbar(message: "", duration: .long)

    class func showErrorMessage(_ messagestr: String) {
        snackbar.message = messagestr
        snackbar.duration = .long

        snackbar.shouldDismissOnSwipe = true
        snackbar.contentInset = UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)

        snackbar.leftMargin = 8
        snackbar.rightMargin = 8

        snackbar.messageTextColor = .white
        snackbar.messageTextFont = UIFont.boldSystemFont(ofSize: 18)

        snackbar.backgroundColor = .red
        snackbar.animationDuration = 0.5
        snackbar.animationType = .slideFromTopBackToTop

        snackbar.show()
    }
    
    class func showNoInternetMessage() {
            snackbar.message = "Please check youy internet connection and try again.!!"
            snackbar.duration = .long

            snackbar.shouldDismissOnSwipe = true
            snackbar.contentInset = UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)

            snackbar.leftMargin = 8
            snackbar.rightMargin = 8

            snackbar.messageTextColor = .white
            snackbar.messageTextFont = UIFont.boldSystemFont(ofSize: 18)

            snackbar.backgroundColor = .red
            snackbar.animationDuration = 0.5
            snackbar.animationType = .slideFromTopBackToTop

            snackbar.show()
    }

    class func dismissErrorMessage() {
        snackbar.dismiss()
    }

    class func showAlertMessage(_ messagestr: String) {
        if messagestr.count > 0 {
            snackbar.message = messagestr
            snackbar.duration = .middle

            snackbar.shouldDismissOnSwipe = true
            snackbar.contentInset = UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)

            snackbar.leftMargin = 8
            snackbar.rightMargin = 8

            snackbar.messageTextColor = .white
            snackbar.messageTextFont = UIFont.boldSystemFont(ofSize: 18)

            snackbar.backgroundColor = .orange
            snackbar.animationDuration = 0.5
            snackbar.animationType = .slideFromTopBackToTop

            snackbar.show()
        }
    }

    class func showSuccessMessage(_ messagestr: String) {
        snackbar.message = messagestr
        snackbar.duration = .middle
        snackbar.shouldDismissOnSwipe = true
        snackbar.contentInset = UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)

        snackbar.leftMargin = 8
        snackbar.rightMargin = 8

        snackbar.messageTextColor = .white
        snackbar.messageTextFont = UIFont.boldSystemFont(ofSize: 18)

        snackbar.backgroundColor = .blue
        snackbar.animationDuration = 0.5
        snackbar.animationType = .slideFromTopBackToTop

        snackbar.show()
    }

    class func showWithActionAndDismissManually(_ messagestr: String, actionName: String, completion:@escaping (String) -> ()) {
        let snackbar1: TTGSnackbar = TTGSnackbar.init(message: messagestr, duration: TTGSnackbarDuration.forever, actionText: actionName) { (snackbar) in
            // Dismiss manually after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
                completion(actionName)
                snackbar.dismiss()
            }
        }

        // Add dismiss callback
        snackbar1.dismissBlock = {
            (snackbar: TTGSnackbar) -> Void in
        }
        snackbar1.animationType = .slideFromTopBackToTop
        snackbar1.show()
    }
}
