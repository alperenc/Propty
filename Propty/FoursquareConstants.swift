//
//  FoursquareConstants.swift
//  Propty
//
//  Created by Alp Eren Can on 28/05/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//

import Foundation

extension FoursquareClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: Client ID & Secret
        static let ClientID = FoursquareKeys.ClientID
        static let ClientSecret = FoursquareKeys.ClientSecret
        
        // MARK: URLs
        static let BaseURL = "https://api.foursquare.com/v2/"
        
        // MARK: Parameter Constants
        static let CategoryID = "4e67e38e036454776db1fb3a"
        static let Intent = "browse"
        static let Radius = "1000"
        
        // MARK: Required Versioning Parameter Constants
        static let Version = "20140806"
        static let Foursquare = "foursquare"
    }
    
    // MARK: Methods
    struct Methods {
        
        // Venue Search
        static let Search = "venues/search"
    }
    
    
    struct ParameterKeys {
        
        // MARK: Parameter Keys
        static let ClientID = "client_id"
        static let ClientSecret = "client_secret"
        static let LatLong = "ll"
        static let CategoryID = "categoryId"
        static let Intent = "intent"
        static let Radius = "radius"
        
        // MARK: Required Versioning Parametere Keys
        static let Version = "v"
        static let Mode = "m"
        
    }
    
    // MARK: JSON Response Keys
    struct ResponseKeys {
        
        // Response
        static let Response = "response"
        
        // Venues
        static let Venues = "venues"
        
    }
}