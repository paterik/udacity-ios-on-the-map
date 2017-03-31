//
//  PRSStudentLocations.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 08.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import Foundation

class PRSStudentLocations {
    
    static let sharedInstance = PRSStudentLocations()
    
    // collection for all student locations
    var locations = [PRSStudentData]()
    // collection for my owned locations
    var myLocations = [PRSStudentData]()
    // collection helper for location object id's (used to unique/cleanUp collection)
    var locationObjectIds = [String]()
    // collection helper for location unique keys (used to unique/cleanUp collection)
    var locationUniqueKeys = [String]()
    
    func clearCollections() {
    
        locations.removeAll()
        myLocations.removeAll()
        
        clearValidatorCache()
    }
    
    func clearValidatorCache() {
        
        locationObjectIds.removeAll()
        locationUniqueKeys.removeAll()
    }
    
    func removeByObjectId(_ objectId: String) {
    
        // remove object by given id from all locations stack
        for (index, location) in locations.enumerated() {
            if location.objectId == objectId {
                locations.remove(at: index)
            }
        }
        
        // remove object by given id from my location stack
        for (index, location) in myLocations.enumerated() {
            if location.objectId == objectId {
                locations.remove(at: index)
            }
        }
        
        // clear validator cache
        clearValidatorCache()
    }
}
