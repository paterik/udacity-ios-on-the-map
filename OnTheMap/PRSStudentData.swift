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
    
    let firstName: String!
    let lastName: String!
    let mediaURL: String!
    let mapString: String!
    let objectId: String!
    let uniqueKey: String!
    let latitude: Double?
    let longitude: Double?
    var studentImage: UIImage?
    let evaluated: Date!
    
    init (_ dictionary: NSDictionary) {
        
        //
        // prepare incomming student meta data, write defaults for
        // nil or unwrappable properties and add an evalation date
        //
        
        firstName = (dictionary["firstName"] as? String!) ?? "-"
        lastName  = (dictionary["lastName"] as? String!)  ?? "-"
        mediaURL  = (dictionary["mediaURL"] as? String!)  ?? "-"
        mapString = (dictionary["mapString"] as? String!) ?? "-"
        objectId  = (dictionary["objectId"] as? String!)  ?? "-"
        uniqueKey = (dictionary["uniqueKey"] as? String!) ?? "-"

        latitude  = (dictionary["latitude"] as? Double!)  ?? nil
        longitude = (dictionary["longitude"] as? Double!) ?? nil

        studentImage = UIImage(named: "icnUserDefault_v1")
        evaluated = Date()
    }
}
