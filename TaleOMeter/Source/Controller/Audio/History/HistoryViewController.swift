//
//  HistoryViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit

class HistoryViewController: UITableViewController {

    // MARK: - Weak Property -
    
    // MARK: - Private Property -
    private var sectionList = [ "23/02/2022", "22/02/2022", "21/02/2022", "20/02/2022" ]
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.backgroundView = UIImageView(image: UIImage(named: "background"))
        tableView.backgroundView?.contentMode = .scaleToFill
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true)
    }
    
    // MARK: - Side Menu button action -
    @IBAction func ClickOnMenu(_ sender: Any) {
        self.sideMenuController!.toggleRightView(animated: true)
    }
    
    @objc func tapOnPlay(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc func tapOnFav(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    // MARK: - UITableViewDataSource -
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionList.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "audioCell", for: indexPath) as? AudioViewCell else { return UITableViewCell() }
        if let image = cell.imageView {
            image.cornerRadius = image.frame.size.height / 2.0
        }
        cell.playButton.addTarget(self, action: #selector(tapOnPlay(_:)), for: .touchUpInside)
        cell.favButton.addTarget(self, action: #selector(tapOnFav(_:)), for: .touchUpInside)
        cell.progressBar.progress = Float.random(in: 0.2..<1.0)
        cell.selectionStyle = .none
        return cell
    }
    
    // MARK: - UITableViewDelegate -
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Core.push(self, storyboard: Storyboard.audio, storyboardId: "NowPlayViewController")
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell") as? AudioViewCell else { return UIView() }
        cell.titleLabel.layer.masksToBounds = true
        cell.titleLabel.layer.cornerRadius = cell.titleLabel.frame.size.height / 2.0
        cell.titleLabel.text = "  \(sectionList[section])  "
        return cell
    }
}
