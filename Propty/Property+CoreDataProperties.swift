//
//  Property+CoreDataProperties.swift
//  Propty
//
//  Created by Alp Eren Can on 29/05/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Property {

    @NSManaged var address: String?
    @NSManaged var city: String?
    @NSManaged var distance: NSNumber?
    @NSManaged var id: String
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var name: String
    @NSManaged var saved: Bool
    @NSManaged var tips: [Tip]?

}
