//
//  ChatViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 02/12/22.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var chatList = [ChatModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "NoDataTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true, titleInLeft: true, backImage: true)
        getChatData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            self.sideMenuController!.toggleRightView(animated: false)
        }
    }
    
    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        self.sideMenuController!.toggleRightView(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ChatViewController {
    // MARK: - Get FAQ data
    @objc func getChatData() {
        if !Reachability.isConnectedToNetwork() {
            Core.noInternet(self, methodName: "getChatData")
            return
        }
        Core.ShowProgress(self, detailLbl: "")
        ChatClient.getChatLists { response in
            if let data = response, data.count > 0 {
                self.chatList = data
            }
            self.tableView.reloadData()
            Core.HideProgress(self)
        }
//        OtherClient.getFAQ { response in
//            if let data = response, data.count > 0 {
//                data.forEach { object in
//                    self.faqSectionList.append(SectionData(isOpen: false, numberOfRows: !object.Answer_audio.isEmpty && !object.Answer_eng.isEmpty ? 2 : 1, item: object))
//                }
//            }
//            self.tableView.reloadData()
//            Core.HideProgress(self)
//        }
    }
}

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatList.count > 0 ? chatList.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.chatList.count <= 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataTableViewCell", for: indexPath) as? NoDataTableViewCell else { return UITableViewCell() }
            return cell
        }
        
        return UITableViewCell()
    }
}

extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.chatList.count > 0 ? UITableView.automaticDimension : 30.0
    }
}



// MARK: - NoInternetDelegate -
extension ChatViewController: NoInternetDelegate {
    func connectedToNetwork(_ methodName: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.perform(Selector((methodName)))
        }
    }
}
