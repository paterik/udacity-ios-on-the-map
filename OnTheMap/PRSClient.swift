//
//  PRSClient.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 27.12.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import Foundation

class PRSClient: NSObject {
    
    //
    // MARK: Constants (Statics)
    //
    static let sharedInstance = PRSClient()

    //
    // MARK: Constants (Normal)
    //
    let debugMode: Bool = true
    let session = URLSession.shared
    let client = RequestClient.sharedInstance
    let students = PRSStudentLocations.sharedInstance
    
    //
    // MARK: Constants (API)
    //
    let apiURL: String = "https://parse.udacity.com/parse/classes/StudentLocation"
    let apiOrderParam: String = "order"
    let apiOrderValue: String = "-updatedAt"
    let apiLimitParam: String = "limit"
    let apiLimitValue: String = "100"
    
    let apiHeaderAuth = [
        "X-Parse-Application-Id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
        "X-Parse-REST-API-Key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    ]
    
    //the the locations of all the students
    func getAllStudentLocations (_ completionHandlerForGetAllLocations: @escaping (_ success: Bool?, _ error: String?) -> Void) {
        
        let apiRequestURL = NSString(format: "%@?%@=%@&%@=%@", apiURL, apiOrderParam, apiOrderValue, apiLimitParam, apiLimitValue)
        
        client.get(apiRequestURL as String, headers: apiHeaderAuth) { (data, error) in
            
            if (error != nil) {
                
                completionHandlerForGetAllLocations(nil, error)
                
            } else {
                
                guard let results = data!["results"] as? [[String: AnyObject]] else {
                    completionHandlerForGetAllLocations(nil, "No results key in the return data")
                    return
                }
                
                self.parseUserLocations(results as [NSDictionary])
                
                completionHandlerForGetAllLocations(true, nil)
            }
        }
    }
    
    func parseUserLocations (_ data: [NSDictionary]) -> Void {
        
        students.locations.removeAll()
        
        for dictionary in data {
            
            let _student = PRSStudentData(
                firstName: (dictionary["firstName"] as? String!) ?? "-",
                lastName:  (dictionary["lastName"] as? String!) ?? "-",
                latitude:  (dictionary["latitude"] as? Double!) ?? nil,
                longitude: (dictionary["longitude"] as? Double!) ?? nil,
                mediaURL:  (dictionary["mediaURL"] as? String!) ?? "-",
                mapString: (dictionary["mapString"] as? String!) ?? "-",
                objectId:  (dictionary["objectId"] as? String!) ?? "-",
                uniqueKey: (dictionary["uniqueKey"] as? String!) ?? "-",
                evaluated: Date()
            )
            
            students.locations.append(_student)
        }
    }
}
