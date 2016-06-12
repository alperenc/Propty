//
//  FoursquareConvenience.swift
//  Propty
//
//  Created by Alp Eren Can on 28/05/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

extension FoursquareClient {
    
    func getVenuesForLocation(location: CLLocation, completion:(success: Bool, error: NSError?) -> Void) {
        
        // Specify parameters
        let parameters = [
            ParameterKeys.LatLong: "\(location.coordinate.latitude),\(location.coordinate.longitude)",
            ParameterKeys.CategoryID: Constants.CategoryID,
            ParameterKeys.Intent: Constants.Intent,
            ParameterKeys.Radius: Constants.Radius]
        
        // Make the request
        taskForGETMethod(Methods.Search, parameters: parameters) { (JSONResult, error) in
            
            guard let result = JSONResult as? [String: AnyObject] else {
                completion(success: false, error: error)
                return
            }
            
            guard let response = result[ResponseKeys.Response] as? [String: AnyObject] else {
                let userInfo = [NSLocalizedDescriptionKey: "No response returned from Foursquare!"]
                completion(success: false, error: NSError(domain: "noResponse", code: 00, userInfo: userInfo))
                return
            }
            
            guard let venuesArray = response[ResponseKeys.Venues] as? [[String: AnyObject]] else {
                let userInfo = [NSLocalizedDescriptionKey: "No such key : venues"]
                completion(success: false, error: NSError(domain: "noSuchKey", code: 01, userInfo: userInfo))
                return
            }
            
            if venuesArray.count < 1 {
                let userInfo = [NSLocalizedDescriptionKey: "No venues found!"]
                completion(success: false, error: NSError(domain: "noVenues", code: 02, userInfo: userInfo))
            } else {
                for venueDictionary in venuesArray {
                    if let propertyId = venueDictionary[ResponseKeys.VenueId] {
                        let fetchRequest = NSFetchRequest(entityName: "Property")
                        fetchRequest.predicate = NSPredicate(format: "id == %@", argumentArray: [propertyId])
                        
                        do {
                            let fetchedProperties = try self.sharedContext.executeFetchRequest(fetchRequest)
                            if fetchedProperties.count > 0 {
                                continue
                            }
                        } catch {}
                        
                    }
                    
                    let _ = Property(dictionary: venueDictionary, context: self.sharedContext)
                }
                
                CoreDataStackManager.sharedInstance.saveContext()
                
                completion(success: true, error: nil)
            }
            
        }
    }
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.managedObjectContext
    }
}
