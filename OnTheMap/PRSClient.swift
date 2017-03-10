//
//  PRSClient.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 27.12.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//
//  this client will use the unity.com parse adaption due to the inavailability of parse.com
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
    let debugMode: Bool = false
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
    
    /**
     * get all available students ordered by last update and limit by the first 100 entities and persisting results into
     * struct base collection if data seems plausible (firstname / lastname / location not empty)
     */
    func getAllStudentLocations (
        _ completionHandlerForGetAllLocations: @escaping (_ success: Bool?, _ error: String?)
        
        -> Void) {
        
        let apiRequestURL = NSString(format: "%@?%@=%@&%@=%@", apiURL, apiOrderParam, apiOrderValue, apiLimitParam, apiLimitValue)
        
        client.get(apiRequestURL as String, headers: apiHeaderAuth) { (data, error) in
            
            if (error != nil) {
                
                completionHandlerForGetAllLocations(nil, error)
                
            } else {
                
                guard let results = data!["results"] as? [[String: AnyObject]] else {
                    completionHandlerForGetAllLocations(nil, "Up's, missing result key in response data")
                    return
                }
                
                self.students.locations.removeAll()
                
                for dictionary in results as [NSDictionary] {
                    let meta = PRSStudentData(dictionary)
                    if self.validateStudentMeta(meta) == true {
                        
                        self.students.locations.append(meta)
                        if self.debugMode == true {
                            print ("\(meta)\n--")
                        }
                    }
                }
                
                // append a single fixture student meta block during development
                self.addSampleStudentLocation()
                
                completionHandlerForGetAllLocations(true, nil)
            }
        }
    }
    
    /*
     * add a sample (fixture) student location, used during development (Loc: Dresden, Zwinger)
     */
    private func addSampleStudentLocation ()
        
        -> Void {
    
        let sampleStudentDict : NSDictionary =
        [
            "firstName": "Patrick",
            "lastName": "Paechnatz",
            "mediaURL": "https://dunkelfrosch.com",
            "mapString": "Dresden, Germany",
            "objectId": "xx9xxYY9ZZ",
            "uniqueKey": "9999999999",
            "latitude": 51.053059,
            "longitude": 13.733758,
        ]

        self.students.locations.append(PRSStudentData(sampleStudentDict))
    }
}
