//
//  FoursquareClient.swift
//  Propty
//
//  Created by Alp Eren Can on 28/05/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//

import UIKit

class FoursquareClient: NSObject {
    
    // MARK: Properties
    
    // Shared session
    var session: NSURLSession
    
    // MARK: Initializers
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> FoursquareClient {
        
        struct Singleton {
            static var sharedInstance = FoursquareClient()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: GET Venues
    func taskForGETMethod(method: String, parameters: [String: AnyObject], completion:(result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        // Set the parameters
        var mutableParameters = parameters
        
        // Add in Client ID & Secret
        mutableParameters[ParameterKeys.ClientID] = Constants.ClientID
        mutableParameters[ParameterKeys.ClientSecret] = Constants.ClientSecret
        mutableParameters[ParameterKeys.Version] = Constants.Version
        mutableParameters[ParameterKeys.Mode] = Constants.Foursquare
        
        // Build the URL and configure the request
        let urlString = Constants.BaseURL + method + FoursquareClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        // Make the request and return the task
        return makeRequest(request, completion: completion)
    
    }
    
    // MARK: Helpers
    
    // Helper: Make the request, check the data and return the task
    func makeRequest(request: NSURLRequest, completion: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            // Was there an error with the request?
            guard error == nil else {
                print("There was an error with your request: \(error)")
                completion(result: nil, error: error)
                return
            }
            
            // Did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                
                let userInfo = [NSLocalizedDescriptionKey : "Invalid response!"]
                completion(result: nil, error: NSError(domain: "invalidResponse", code: 0, userInfo: userInfo))
                
                return
            }
            
            // Was there any data returned?
            guard let data = data else {
                print("No data was returned by the request!")
                let userInfo = [NSLocalizedDescriptionKey : "No data returned!"]
                completion(result: nil, error: NSError(domain: "noData", code: 1, userInfo: userInfo))
                return
            }
            
            // Return data in completion
            FoursquareClient.parseJSONWithCompletionHandler(data, completionHandler: completion)
        }
        
        // Start the request
        task.resume()
        
        return task
        
    }
    
    // Helper: Given raw JSON, return a usable Foundation object
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 2, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
    
    // Helper function: Given a dictionary of parameters, convert to a string for a url
    class func escapedParameters(parameters: [String: AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }

}
