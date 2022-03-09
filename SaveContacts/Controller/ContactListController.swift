//
//  ContactListController.swift
//  SaveContacts
//
//  Created by sanaboina  prasad on 07/03/22.
//

import Contacts
import ContactsUI
import UIKit

class ContactListController: UITableViewController {
    
    
//    Mark: - Properties
    private let cellIdentifier = "cell"
    private let searchController = UISearchController(searchResultsController: nil)
    private var contacts = [Contact]()
    private var contactDic = [String: [Contact]]()
    private var contact_sec_titles = [String]()
    private var isSearchController = false
    
    
//    Mark: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
       configureUI()
       fetchContact()
    }
    
    private func fetchContact(){
        contacts = DataBaseHelper.sharedInstance.getContactInfo()
        for item in contacts {
            let contactKey = (item.firstname?.prefix(1)) ?? ""
            
            if var contactValues = contactDic[String(contactKey)]{
                contactValues.append(item)
                contactDic[String(contactKey)] = contactValues
            }else{
              contactDic[String(contactKey)] = [item]
            }
        }
        contact_sec_titles = [String](contactDic.keys)
        contact_sec_titles = contact_sec_titles.sorted(by: {$0 < $1})
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func configureUI(){
        title = "Contacts"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Groups", style: .plain, target: self, action: #selector(didTapGroups))
        tableView.register(ContactCell.self, forCellReuseIdentifier: cellIdentifier)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.automaticallyShowsCancelButton = true
        searchController.delegate = self
        searchController.searchBar.placeholder = "Search Contacts"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    @objc private func didTapAdd(){
        self.navigationController?.isNavigationBarHidden = false
        let con = CNContact()
        let vc = CNContactViewController(forNewContact: con)
        vc.delegate = self
        self.present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    @objc private func didTapGroups(){
        print("DEBUG: did tap on Groups")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return contact_sec_titles.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let contactKey = contact_sec_titles[section]
        if let contactvalues = contactDic[contactKey]{
            return contactvalues.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ContactCell
        
        let contactKey = contact_sec_titles[indexPath.section]
        if let contactValues = contactDic[contactKey]{
            let first_name = contactValues[indexPath.row].firstname ?? ""
            let last_name = contactValues[indexPath.row].lastname ?? ""
            cell.textLabel?.text =  first_name + " " + last_name
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return contact_sec_titles[section]
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return contact_sec_titles
    }
}




extension ContactListController: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text  = searchController.searchBar.text?.lowercased() else { return}
        contactDic = ["": []]
        contact_sec_titles = []
    
        for item in contacts {
            guard let value = item.firstname?.lowercased() else { return}
            if value.contains(text){
                if var contactValues = contactDic[String("")]{
                    contactValues.append(item)
                    contactDic[String("")] = contactValues
                }else{
                  contactDic[String("")] = [item]
                }
            }
        }
        contact_sec_titles = [""]
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

//Mark: - UISearchControllerDelegate

extension ContactListController: UISearchControllerDelegate {
    
    func didDismissSearchController(_ searchController: UISearchController) {
        self.fetchContact()
    }
}

//Mark:- CNContactViewControllerDelegate

extension ContactListController: CNContactViewControllerDelegate {
    
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        var mobile_no = ""
        if let phoneNumbers:[CNLabeledValue<CNPhoneNumber>] = contact?.phoneNumbers {
            if  let firstPhoneNumber:CNPhoneNumber = phoneNumbers.first?.value {
                let primaryPhoneNumberStr:String = firstPhoneNumber.stringValue
                mobile_no = primaryPhoneNumberStr
            }
        }
        if contact?.givenName != "" && contact?.givenName != "" && mobile_no != ""{
            let familyname = contact?.familyName ?? ""
            let givenName = contact?.givenName.capitalized ?? ""
            let dict: [ContactInfo: String] = [.firstname:givenName,.lastname:familyname,.mobile:mobile_no]
            DataBaseHelper.sharedInstance.saveContact(object: dict)
        }
        self.dismiss(animated: true) { [self] in
            contacts = []
            contactDic = [:]
            contact_sec_titles = []
            fetchContact()
        }
    }
    
    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        return true
    }
    
}
