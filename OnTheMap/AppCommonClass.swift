//
//  AppCommonClass.swift
//  OnTheMap
//
// This class hold all application related base/helper functions
//
//  Created by Patrick Paechnatz on 04.04.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit
import MapKit

class AppCommonClass {

    //
    // MARK: Constants (Statics)
    //
    
    static let sharedInstance = AppCommonClass()
    
    //
    // MARK: Constants (Normal)
    //
    
    let locationDistanceDivider: Double = 1000.0
    let locationDistanceUnitMeter: String = "m"
    let locationDistanceUnitKilometer: String = "km"
    
    //
    // MARK: Constants (Normal)
    //
    
    /*
     * get the printable (human readable) distance between two locations (using fix metric system)
     */
    func getDistanceWithUnitBetween(
       _ sourceLocation: CLLocation!,
       _ targetLocation: CLLocation!) -> String {
        
        return getDistanceWithUnit(sourceLocation.distance(from: targetLocation))
    }
    
    /*
     * get the printable distance (including units, using fix metric system) by given distanceValue
     */
    func getDistanceWithUnit(_ distanceValue: Double) -> String {
        
        // render distance in unit meter firstly
        var distanceOut: String! = NSString(format: "%.0f %@", distanceValue, "m") as String
        // render distance in kilometer on specific threshold value
        if distanceValue >= locationDistanceDivider {
            distanceOut = NSString(format: "%.0f %@", (distanceValue / locationDistanceDivider), "km") as String
        }
        
        return distanceOut
    }
}
