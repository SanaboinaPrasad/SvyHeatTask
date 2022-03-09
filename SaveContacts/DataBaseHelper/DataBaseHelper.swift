//
//  DataBaseHelper.swift
//  SaveContacts
//
//  Created by sanaboina  prasad on 08/03/22.
//

import UIKit
import CoreData

enum ContactInfo: String {
    case firstname = "firstname"
    case lastname = "lastname"
    case mobile = "mobile"
}

class DataBaseHelper {
    let entityName = "Contact"
   static let sharedInstance = DataBaseHelper()
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
   
    func saveContact(object: [ContactInfo: String]){
        let person = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context!) as! Contact
        person.firstname = object[.firstname]
        person.lastname = object[.lastname]
        person.mobile = object[.mobile]
        do {
            try context?.save()
        }
        catch {
            print("data is not saved")
        }
    }
    
    func getContactInfo() ->[Contact]{
       var contact = [Contact]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do{
            contact = try context?.fetch(fetchRequest) as! [Contact]
        }catch{
            print("cannot get data")
        }
        return contact
    }
}
