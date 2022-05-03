//
//  CountryViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 14/02/22.
//

import UIKit

// MARK: - Protocol used for sending data back -
protocol CountryCodeDelegate: AnyObject {
    func selectedCountryCode(country: Country)
}

class CountryViewController: UIViewController {
    
    // MARK: - Weak Properties -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    // Making this a weak variable, so that it won't create a strong reference cycle
    weak var delegate: CountryCodeDelegate? = nil
    
    // MARK: - Private Properties -
    private var list: [Country] = [Country]()
    private var dupList: [Country] = [Country]()
    private var viewOriHeight: CGFloat = 0
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Select Country"
        self.hideKeyboard()
        configuration()
        self.searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.leftView?.tintColor = .white

        viewOriHeight = self.view.frame.size.height
        self.tableView.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "NoDataTableViewCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: false)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShowNotification (notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue  {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [self] in
                self.view.frame.size.height = viewOriHeight - keyboardHeight
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc private func keyboardWillHideNotification (notification: Notification) {
       // if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue  {
            //let keyboardRectangle = keyboardFrame.cgRectValue
            //let keyboardHeight = keyboardRectangle.height
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: { [self] in
                self.view.frame.size.height = viewOriHeight
                self.view.layoutIfNeeded()
            }, completion: nil)
        //}
    }
    
    private func configuration() {
        for code in NSLocale.isoCountryCodes  {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_US").displayName(forKey: NSLocale.Key.identifier, value: id)
            
            let locale = NSLocale.init(localeIdentifier: id)
            
            let countryCode = locale.object(forKey: NSLocale.Key.countryCode)
            //let currencyCode = locale.object(forKey: NSLocale.Key.currencyCode)
            //let currencySymbol = locale.object(forKey: NSLocale.Key.currencySymbol)
            
            if name != nil {
                let model = Country()
                model.name = name
                model.countryCode = countryCode as? String
               // model.currencyCode = currencyCode as? String
               // model.currencySymbol = currencySymbol as? String
                model.flag = String.flag(for: code)
                if NSLocale().extensionCode(countryCode: model.countryCode) != nil {
                    model.extensionCode = "+\(NSLocale().extensionCode(countryCode: model.countryCode) ?? "")"
                    list.append(model)
                }
            }
        }
        self.dupList = self.list
        self.tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate - UITableViewDataSource -
extension CountryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dupList.count > 0 ? dupList.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.dupList.count <= 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataTableViewCell", for: indexPath) as? NoDataTableViewCell else { return UITableViewCell() }
            cell.titleLabel.text = "No result found!"
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return UITableViewCell() }
        if let txtLable = cell.textLabel {
            txtLable.text = "\(dupList[indexPath.row].flag!) \(dupList[indexPath.row].extensionCode!) - \(dupList[indexPath.row].name!)"
            txtLable.textColor = .white
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectedCountryCode(country: dupList[indexPath.row])
        self.navigationController?.popViewController(animated: true)
//        dismiss(animated: true)
    }
}

// MARK: - UISearchBarDelegate -
extension CountryViewController : UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text =  ""
        searchBar.endEditing(true)
        
        self.dupList = self.list
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.dupList = searchText.isEmpty ? list : list.filter({ (model) -> Bool in
            return model.name!.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil || model.extensionCode!.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        self.tableView.reloadData()
    }
}
