//
//  MapViewLocationManager.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 10.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit
import CoreLocation

class MapViewLocationManager {
    
    //
    // MARK: Constants (Statics)
    //
    static let sharedInstance = MapViewLocationManager()
    
    //
    // MARK: Constants (Normal)
    //
    let locationManager = CLLocationManager()
    let debugMode: Bool = false
    
    //
    // MARK: Variables
    //
    var doThisWhenAuthorized : (() -> ())?
    
    func checkForLocationAccess(always:Bool = false, andThen f: (()->())? = nil) {
        
        guard CLLocationManager.locationServicesEnabled() else {
            
            self.locationManager.startUpdatingLocation()
            
            return
        }

        switch CLLocationManager.authorizationStatus()
        {
            case .authorizedAlways, .authorizedWhenInUse: f?()
            case .notDetermined:
                self.doThisWhenAuthorized = f
                always ?
                    self.locationManager.requestAlwaysAuthorization() :
                    self.locationManager.requestWhenInUseAuthorization()
            
            case .restricted:
                
                if debugMode { print ("restricted location access granted, not enough permissions for this application :(") }
                
                break
            
            case .denied:
                
                if debugMode { print ("location access denied, really? Not enough permissions for this application :(") }
                
                break
        }
    }
}
