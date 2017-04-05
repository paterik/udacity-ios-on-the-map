//
//  PRSStudentLocations.swift
//  OnTheMap
//  ClassMethod(s)
//
//  - func clearCollections    () -> Void :: clean up all collections
//  - func clearValidatorCache () -> Void :: clean up my validation cache
//  - func removeByObjectId    () -> Void :: remove a specific object from all collections using objectId
//
//
//  Extension(s)
//
//  -/-
//
//  Created by Patrick Paechnatz on 08.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import Foundation

class PRSStudentLocations {
    
    //
    // MARK: Constants (Statics)
    //
    static let sharedInstance = PRSStudentLocations()
    
    //
    // MARK: Variables
    //

    // collection for new student locations dictionary feature implementation
    var locExt = [NSDictionary]()
    // collection for all student locations
    var listLocations: [PRSStudentData]!
    // collection for all student locations
    var locations = [PRSStudentData]()
    // collection for my owned locations
    var myLocations = [PRSStudentData]()
    // collection helper for location object id's (used to unify student positions)
    var locationObjectIds = [String]()
    // collection helper for location unique keys (used to unify student positions)
    var locationUniqueKeys = [String]()
    // collection helper for location position keys (also used to unify student positions)
    var locationCoordinateKeys = [String]()
    
    //
    // MARK: Methods (Public)
    //
    
    /*
     * clean up all collections
     */
    func clearCollections() {
    
        locations.removeAll()
        myLocations.removeAll()
        
        clearValidatorCache()
    }
    
    /*
     * clean up my validation cache
     */
    func clearValidatorCache() {
        
        locationObjectIds.removeAll()
        locationUniqueKeys.removeAll()
        locationCoordinateKeys.removeAll()
    }
    
    /*
     * find a specific object from all collections using objectId
     */
    func findIndexByObjectId(_ objectId: String) -> Int? {
        
        // remove object by given id from all locations stack
        for (index, location) in locations.enumerated() {
            if location.isHidden == false && location.objectId == objectId {
                return index
            }
        }
        
        return nil
    }
    
    /*
     * remove a specific object from all collections using objectId
     */
    func removeByObjectId(_ objectId: String) {
    
        if let objextIndex = findIndexByObjectId(objectId) {
            locations.remove(at: objextIndex)
        }
        
        if let objextIndex = findIndexByObjectId(objectId) {
            myLocations.remove(at: objextIndex)
        }
        
        // clear validator cache
        clearValidatorCache()
    }
}
