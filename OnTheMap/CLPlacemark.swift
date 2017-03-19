//
//  CLPlacemark.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 19.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import Foundation
import MapKit

extension CLPlacemark {
    
    var compactAddress: String? {
        
        if let name = name {
            
            var result = name
            
            if let _street = thoroughfare {
                result += ", \(_street)"
            }
            
            if let _zipCode = postalCode {
                result += ", \(_zipCode)"
            }
            
            if let _city = locality {
                result += " \(_city)"
            }
            
            if let _country = country {
                result += " (\(_country))"
            }
            
            return result
        }
        
        return nil
    }
}
