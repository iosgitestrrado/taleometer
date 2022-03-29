//
//  TRPostViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 03/03/22.
//

import UIKit
import AVKit

class TRPostViewController: UIViewController {
    
    // MARK: - Weak Properties -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tblBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Public Properties -
    var categoryId = -1
    
    // MARK: - Private Properties -
//    private struct QuestionModel {
//        var question = String()
//        var answer = String()
//        var value = String()
//        var videoUrl = ""
//        var image = String()
//    }
//    private var questionArray: [QuestionModel] = {
//        var questionArraytemp = [QuestionModel]()
//        questionArraytemp.append(QuestionModel(question: "Who is the Character in this Image?", answer: "Tenali Raman", value: "", videoUrl: "", image: "tenali.jpg"))
//        questionArraytemp.append(QuestionModel(question: "Watch video and answer the question in it", answer: "Dummy Video", value: "", videoUrl: "https://v.pinimg.com/videos/720p/77/4f/21/774f219598dde62c33389469f5c1b5d1.mp4", image: "acastro_180403_1777_youtube_0001.jpg"))
//        questionArraytemp.append(QuestionModel(question: "Where to go in Japan?", answer: "Tokyo", value: "", videoUrl: "", image: "YouTube-thumbnail-maker-1.png"))
//        return questionArraytemp
//    }()
    
    private var postArray = [TriviaPost]()
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboard()
        self.getTriviaPosts()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true, titleInLeft: false, backImage: true, backImageColor: .red, bigfont: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        self.sideMenuController!.toggleRightView(animated: true)
    }
    
    // MARK: Tap on submit Button
    @objc private func tapOnSubmit(_ sender: UIButton) {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        if postArray[sender.tag].Value.isBlank, let textFlield = postArray[sender.tag].TextField {
            Validator.showRequiredError(textFlield)
            return
        }
        Core.ShowProgress(self, detailLbl: "Submitting Answer...")
        TriviaClient.submitAnswer(SubmitAnswerRequest(post_id: postArray[sender.tag].Post_id, answer: postArray[sender.tag].Value)) { [self] status in
            Core.HideProgress(self)
            if let st = status, st {
                if let myobject = UIStoryboard(name: Constants.Storyboard.trivia, bundle: nil).instantiateViewController(withIdentifier: "TRFeedViewController") as? TRFeedViewController {
                    postArray[sender.tag].Value = ""
                    self.tableView.reloadData()
                    //myobject.postData.append(postArray[sender.tag])
                    self.navigationController?.pushViewController(myobject, animated: true)
                }
            }
        }
    }
    
    // MARK: Tap on video Button
    @objc private func tapOnVideo(_ sender: UIButton) {
        if !postArray[sender.tag].QuestionVideoURL.isBlank {
            // Play a video in video controller
            guard let videoURL = URL(string: postArray[sender.tag].QuestionVideoURL) else { return }
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            playerViewController.showsPlaybackControls = true
            self.present(playerViewController, animated: true) {
                playerViewController.player?.play()
            }
        } else {
            Toast.show("No video found!")
        }
    }
    
    // MARK: Keyboard will show
    @objc private func keyboardWillShowNotification (notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue  {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.tblBottomConstraint.constant = keyboardHeight
        }
    }
    
    // MARK: Keyboard will Hide
    @objc private func keyboardWillHideNotification (notification: Notification) {
        self.tblBottomConstraint.constant = 0
    }
}

extension TRPostViewController {
    // MARK: - Get trivia posts
    private func getTriviaPosts() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self)
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        if categoryId >= 0 {
            // MARK: - Get trivia posts by category
            TriviaClient.getCategoryPosts(1, req: TriviaCategoryRequest(category: categoryId)) { [self] response in
                if let data = response {
                    postArray = data
                }
                tableView.reloadData()
                Core.HideProgress(self)
            }
        } else {
            // MARK: - Get trivia daily posts
            TriviaClient.getTriviaDailyPost(1) { [self] response in
                if let data = response {
                    postArray = data
                }
                tableView.reloadData()
                Core.HideProgress(self)
            }
        }
    }
}

// MARK: - UITableViewDataSource -
extension TRPostViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as? PostCellView else { return UITableViewCell() }
        let cellData = postArray[indexPath.row]
        cell.configureCell(cellData.Question, value: cellData.Value, coverImage: defaultImage, videoUrl: cellData.QuestionVideoURL, row: indexPath.row, target: self, selectors: [#selector(tapOnSubmit(_:)), #selector(tapOnVideo(_:))])
        if let textField = cell.answerText {
            postArray[indexPath.row].TextField = textField
        }
        return cell
    }
}

// MARK: - UITableViewDelegate -
extension TRPostViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 292
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

// MARK: - UITextFieldDelegate -
extension TRPostViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let indexPath = IndexPath(row: textField.tag, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.postArray[textField.tag].Value = textField.text!
        if textField.text!.isBlank {
            Validator.showRequiredError(textField)
            return
        }
    }
}
