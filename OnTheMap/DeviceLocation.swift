//
//  DeviceLocation.swift
//  OnTheMap
//
//  simple persistence model for device location
//
//  Created by Patrick Paechnatz on 10.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit

struct DeviceLocation {
    
    let latitude: Double?
    let longitude: Double?
    let determined: Date!
    
    init (_ dictionary: NSDictionary) {
        
        latitude  = (dictionary["latitude"] as? Double!)  ?? nil
        longitude = (dictionary["longitude"] as? Double!) ?? nil
        determined = Date()
    }
}
