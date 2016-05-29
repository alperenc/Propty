//
//  Tip+CoreDataProperties.swift
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

extension Tip {

    @NSManaged var text: String?
    @NSManaged var createdAt: NSDate?
    @NSManaged var property: Property?

}
