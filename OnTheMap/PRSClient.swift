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
import UIKit
import MapKit

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
    let clientUdacity = UDCClient.sharedInstance
    let clientGoogle = GClient.sharedInstance
    let clientFacebook = FBClient.sharedInstance
    
    //
    // MARK: Constants (Specials)
    //
    
    let metaCountryUnknownFlag = "🏴"
    let metaCountryUnknown = "unknown country"
    let metaDateTimeFormat: String! = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let students = PRSStudentLocations.sharedInstance
    let clientGoogleThreshold = 4 // request throttle, 4 means 1000/4 = 250ms

    //
    // MARK: Constants (API)
    //
    
    let apiURL: String = "https://parse.udacity.com/parse/classes/StudentLocation"
    let apiWhereParam: String = "where"
    let apiOrderParam: String = "order"
    let apiOrderValue: String = "-updatedAt"
    let apiLimitParam: String = "limit"
    let apiLimitValue: String = "100"
    
    let apiHeaderAuth = [
        "X-Parse-Application-Id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
        "X-Parse-REST-API-Key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    ]
    
    //
    // MARK: Variables
    //
    
    var sessionUdacity: UDCSession?
    var sessionFacebook: FBSession?
    var sessionParamString: String?
    var metaMyLocationsCount: Int?
    var metaStudentLocationsCount: Int?
    var metaStudentLocationsCountValid: Int?
    
    /*
     * set current user location object (as new student location)
     */
    func setStudentLocation (
       _ studentData: PRSStudentData?,
       _ completionHandlerForSetCurrentLocation: @escaping (_ success: Bool?, _ error: String?) -> Void) {
        
        let studentDataArray = prepareStudentMetaForPostRequest(studentData)!
        
        client.post(apiURL, headers: apiHeaderAuth, jsonBody: studentDataArray as [String : AnyObject]?)
        {
            (data, error) in
            
            if (error != nil) {
                
                completionHandlerForSetCurrentLocation(false, "Up's, your request couln't be handled ... \(String(describing: error))")
                
            } else {
                
                completionHandlerForSetCurrentLocation(true, nil)
            }
        }
    }
    
    /*
     * update a specific user location object
     */
    func updateStudentLocation (
       _ studentData: PRSStudentData?,
       _ completionHandlerForUpdateCurrentLocation: @escaping (_ success: Bool?, _ error: String?) -> Void) {
        
        let apiRequestURL = NSString(format: "%@/%@", apiURL, studentData!.objectId!)
        let studentDataArray = prepareStudentMetaForPutRequest(studentData!)
        
        completionHandlerForUpdateCurrentLocation(true, nil)
        client.put(apiRequestURL as String, headers: apiHeaderAuth, jsonBody: studentDataArray as [String : AnyObject]?)
        {
            (data, error) in
            
            if (error != nil) {
                
                completionHandlerForUpdateCurrentLocation(false, "Up's, your request couln't be handled ... \(String(describing: error))")
                
            } else {
                
                completionHandlerForUpdateCurrentLocation(true, nil)
            }
        }
    }
    
    /*
     * delete a specific user location object
     */
    func deleteStudentLocation (
       _ studentDataObjectId: String!,
       _ completionHandlerForDeleteCurrentLocation: @escaping (_ success: Bool?, _ error: String?) -> Void) {
        
        let apiRequestURL = NSString(format: "%@/%@", apiURL, studentDataObjectId)
        
        client.delete(apiRequestURL as String, headers: apiHeaderAuth)
        {
            (data, error) in
            
            if (error != nil) {
                
                completionHandlerForDeleteCurrentLocation(false, "Up's, your request couln't be handled ... \(String(describing: error))")
                
            } else {
                
                completionHandlerForDeleteCurrentLocation(true, nil)
            }
        }
    }
    
    /*
     * get the current user location object and check corresponding student location
     */
    func getMyStudentLocations (
       _ completionHandlerForCurrentLocation: @escaping (_ success: Bool?, _ error: String?) -> Void) {
        
        guard let sessionUdacity = clientUdacity.clientSession else {
            completionHandlerForCurrentLocation(false, "Up's, no active udacity user session were found! Are you still logged in?")
            return
        }
        
        let sessionParamString = getJSONFromStringArray([ "uniqueKey" : sessionUdacity.accountKey! ]) // "6063512956"
        let sessionParamStringEscaped = sessionParamString.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        let apiRequestURL = NSString(format: "%@?%@=%@", apiURL, apiWhereParam, sessionParamStringEscaped!)
        
        client.get(apiRequestURL as String, headers: apiHeaderAuth)
        {
            (data, error) in
            
            if (error != nil) {
                
                completionHandlerForCurrentLocation(false, "Up's, your request couln't be handled ... \(String(describing: error))")
                
            } else {
                
                guard let results = data!["results"] as? [[String: AnyObject]] else {
                    completionHandlerForCurrentLocation(false, "Up's, missing result key in response data")
                    
                    return
                }
                
                self.students.myLocations.removeAll()
                self.students.clearValidatorCache()
                
                for dictionary in results as [NSDictionary] {
                    
                    let meta = PRSStudentData(dictionary)
                    self.students.myLocations.append(meta)
                    if self.debugMode { print ("\(meta)\n--") }
                }
                
                self.metaMyLocationsCount = self.students.myLocations.count
                completionHandlerForCurrentLocation(true, nil)
            }
        }
    }
    
    /**
     * get all available students ordered by last update and limit by the first 100 entities and persisting results into
     * struct base collection if data seems plausible (firstname / lastname / location not empty)
     */
    func getAllStudentLocations (
       _ completionHandlerForGetAllLocations: @escaping (_ success: Bool?, _ error: String?) -> Void) {
        
        guard let sessionUdacity = clientUdacity.clientSession else {
            completionHandlerForGetAllLocations(false, "Up's, no active udacity user session were found! Are you still logged in?")
            return
        }
        
        let apiRequestURL = NSString(format: "%@?%@=%@&%@=%@", apiURL, apiOrderParam, apiOrderValue, apiLimitParam, apiLimitValue)
        
        client.get(apiRequestURL as String, headers: apiHeaderAuth)
        {
            (data, error) in
            
            if (error != nil) {
                completionHandlerForGetAllLocations(false, "Up's, your request couln't be handled ... \(String(describing: error))")
                
            } else {
                
                guard let results = data!["results"] as? [[String: AnyObject]] else {
                    completionHandlerForGetAllLocations(false, "Up's, missing result key in response data")
                    
                    return
                }
                
                self.students.clearCollections()
                
                for dictionary in results as [NSDictionary] {
                
                    let meta = PRSStudentData(dictionary)
                    if self.validateStudentMeta(meta) == true {
                        // add all relevant locations in collection
                        self.students.locations.append(meta)
                        // add owned locations in separate collection
                        if meta.uniqueKey != nil && meta.uniqueKey == sessionUdacity.accountKey! {
                            self.students.myLocations.append(meta)
                        }
                        
                        if self.debugMode { print ("\(meta)\n--") }
                    }
                }
                
                // enrich students meta information using google's map api
                self.enrichStudentMeta()
                
                // add some meta statistics
                self.metaStudentLocationsCountValid = self.students.locations.count
                self.metaStudentLocationsCount = results.count
                
                completionHandlerForGetAllLocations(true, nil)
            }
        }
    }
    
    /*
     * [ DBG/DEV ] add a sample (fixture) student location, only used during development (Loc: Dresden, Zwinger)
     */
    private func addSampleStudentLocation ()
        
        -> Void {
    
        let sampleStudentDict : NSDictionary =
        [
            "firstName": "Robert",
            "lastName": "Heidmann",
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
