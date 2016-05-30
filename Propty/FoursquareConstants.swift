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
        static let Radius = 1000
    }
    
    // MARK: Methods
    struct Methods {
        
        // Venue Search
        static let Search = "venues/search"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        
        static let ClientID = "client_id"
        static let ClientSecret = "client_secret"
        static let LatLong = "ll"
        static let CategoryID = "category_id"
        static let Intent = "intent"
        static let Radius = "radius"
        
    }
    
    // MARK: JSON Response Keys
    struct ResponseKeys {
        
        // Response
        static let Response = "response"
        
        // Venues
        static let Venues = "venues"
        
    }
}