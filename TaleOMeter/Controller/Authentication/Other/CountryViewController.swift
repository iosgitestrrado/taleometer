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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var list: [Country] = [Country]()
    var dupList: [Country] = [Country]()
    
    // Making this a weak variable, so that it won't create a strong reference cycle
    weak var delegate: CountryCodeDelegate? = nil
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Select Country"
        configuration()
    }
    
    func configuration() {
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
        return dupList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = "\(dupList[indexPath.row].flag!) \(dupList[indexPath.row].extensionCode!) - \(dupList[indexPath.row].name!)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectedCountryCode(country: dupList[indexPath.row])
        dismiss(animated: true)
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.dupList = searchText.isEmpty ? list : list.filter({ (model) -> Bool in
            return model.name!.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil || model.extensionCode!.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        self.tableView.reloadData()
    }
}
