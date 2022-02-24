//
//  AudioListViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 22/02/22.
//

import UIKit

class AudioListViewController: UITableViewController {

    // MARK: - Public Property -
    public var isFavourite = false
    public var isNonStop = false

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func tapOnPlay(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc func tapOnFav(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
        
    // MARK: - UITableViewDataSource -
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "audioCell", for: indexPath) as? AudioViewCell else { return UITableViewCell() }
        if let image = cell.imageView {
            image.cornerRadius = image.frame.size.height / 2.0
        }
        cell.playButton.isHidden = isNonStop
        cell.favButton.isHidden = isNonStop
        if !isNonStop {
            cell.playButton.addTarget(self, action: #selector(tapOnPlay(_:)), for: .touchUpInside)
            cell.favButton.addTarget(self, action: #selector(tapOnFav(_:)), for: .touchUpInside)
            if isFavourite {
                cell.favButton.isSelected = isFavourite
            }
        }
        cell.selectionStyle = .none
        return cell
    }
    
    // MARK: - UITableViewDelegate -
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
