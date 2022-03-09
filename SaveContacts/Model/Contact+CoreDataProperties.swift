//
//  Contact+CoreDataProperties.swift
//  SaveContacts
//
//  Created by sanaboina  prasad on 08/03/22.
//
//

import Foundation
import CoreData


extension Contact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }

    @NSManaged public var firstname: String?
    @NSManaged public var lastname: String?
    @NSManaged public var mobile: String?

}

extension Contact : Identifiable {

}
