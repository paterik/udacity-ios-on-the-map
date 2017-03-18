//
//  PRSStudentData.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 27.12.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import Foundation
import UIKit

struct PRSStudentData {
    
    let objectId: String!
    let uniqueKey: String!
    
    let firstName: String!
    let lastName: String!
    let mapString: String!
    let mediaURL: String!
    
    let latitude: Double?
    let longitude: Double?
    
    let createdAt: Date!
    let updatedAt: Date!
    
    var asArray: [String : Any] {
        get {
            return [
                "firstName": firstName ?? " ",
                "lastName": lastName ?? " ",
                "mediaURL": mediaURL ?? " ",
                "mapString": mapString ?? " ",
                "objectId": objectId ?? " ",
                "uniqueKey": uniqueKey ?? " ",
                "latitude": latitude!,
                "longitude": longitude!
                
            ] as [String : Any]
        }
    }
    
    init (_ dictionary: NSDictionary) {
        
        //
        // prepare incomming student meta data, write defaults for
        // nil or unwrappable properties and add an evalation date
        //
        
        let metaDefault: String! = "-"
        
        firstName = (dictionary["firstName"] as? String!) ?? metaDefault
        lastName  = (dictionary["lastName"] as? String!)  ?? metaDefault
        mediaURL  = (dictionary["mediaURL"] as? String!)  ?? metaDefault
        mapString = (dictionary["mapString"] as? String!) ?? metaDefault
        objectId  = (dictionary["objectId"] as? String!)  ?? metaDefault
        uniqueKey = (dictionary["uniqueKey"] as? String!) ?? metaDefault

        latitude  = (dictionary["latitude"] as? Double!)  ?? 0.0
        longitude = (dictionary["longitude"] as? Double!) ?? 0.0

        createdAt = Date()
        updatedAt = Date()
    }
}
