//
//  Property.swift
//  Propty
//
//  Created by Alp Eren Can on 29/05/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//

import Foundation
import CoreData


class Property: NSManagedObject {
    
    struct Keys {
        static let ID = "id"
        static let Name = "name"
        static let Location = "location"
        static let Lat = "lat"
        static let Long = "lng"
        static let Distance = "distance"
        static let Address = "address"
        static let City = "city"
        
    }
    
    // Standard Core Data init method
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    // Init with dictionary
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity = NSEntityDescription.entityForName("Property", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        id = dictionary[Keys.ID] as! String
        name = dictionary[Keys.Name] as! String
        saved = false
        
        guard let location = dictionary[Keys.Location] as? [String: AnyObject] else {
            return
        }
        
        latitude = location[Keys.Lat] as? NSNumber
        longitude = location[Keys.Long] as? NSNumber
        distance = location[Keys.Distance] as? NSNumber
        address = location[Keys.Address] as? String
        city = location[Keys.City] as? String
    }

}
