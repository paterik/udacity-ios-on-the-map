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
    
    var compactAdress: String? {
    
        if let _ = locality {
        
            var addressString:String = ""
            
            if let _street = thoroughfare {
                addressString += "\(_street), "
            }
            
            if let _zipCode = postalCode {
                addressString += "\(_zipCode)"
            }
            
            if let _city = locality {
                addressString += " \(_city)"
            }
            
            if let _country = country {
                addressString += ", \(_country)"
            }
            
            return addressString
        }
        
        return nil
    }
    
    var fullAddress: String? {
        
        if let _ = locality {
            
            var addressString:String = ""
            
            if let _name = name {
                addressString += "\(_name), "
            }
            
            if let _street = thoroughfare {
                addressString += "\(_street), "
            }
            
            if let _zipCode = postalCode {
                addressString += "\(_zipCode)"
            }
            
            if let _city = locality {
                addressString += " \(_city)"
            }
            
            if let _country = country {
                addressString += ", \(_country)"
            }
            
            return addressString
        }
        
        return nil
    }
}
