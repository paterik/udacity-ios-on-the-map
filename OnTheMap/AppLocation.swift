//
//  AppLocation.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 09.04.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class AppLocation: NSObject, CLLocationManagerDelegate {

    //
    // MARK: Constants (Statics)
    //
    
    static let sharedInstance = AppLocation()
    
    //
    // MARK: Constants (Special)
    //
    
    let debugMode: Bool = false
    let deviceLocationManager = DeviceLocationManager.sharedInstance
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //
    // MARK: Constants (Normal)
    //
    
    let locationAccuracy : CLLocationAccuracy = 10       // accuracy factor for device location
    let locationCheckTimeout : TimeInterval = 10         // timeout for device location fetch
    let locationDistanceDivider : Double = 1000.0        // rate for metric conversion (m -> km)
    let locationDistanceHook : Double = 50               // minimum distance (measured in meters) before an update
    let locationFetchMode : Int8 = 2                     // 1: saveMode, 2: quickMode
    let locationCoordRound : Int = 6                     // round factor for coordinate comparison
    
    //
    // MARK: Variables
    //
    
    var locationFetchTrying : Bool = false
    var locationFetchSuccess : Bool = false
    var locationFetchStartTime : Date!
    var locationManager : CLLocationManager { return self.deviceLocationManager.locationManager }
    
    //
    // MARK: Public Methods
    //
    
    /*
     * update location meta information and (re)positioning current mapView
     */
    func updateCurrentLocationMeta(
       _ coordinate: CLLocationCoordinate2D) {
        
        let currentDeviceLocation : NSDictionary = [ "latitude": coordinate.latitude, "longitude": coordinate.longitude ]
        
        appDelegate.currentDeviceLocations.removeAll() // currently we won't persist all evaluated device locations
        appDelegate.currentDeviceLocations.append(DeviceLocation(currentDeviceLocation)) // persist device location
        appDelegate.useCurrentDeviceLocation = true
        appDelegate.useLongitude = coordinate.longitude
        appDelegate.useLatitude = coordinate.latitude
        
        locationFetchSuccess = true
        if debugMode == true {
            print("-------------------------------------------------------------")
            print("You are at [\(coordinate.latitude)] [\(coordinate.longitude)]")
            print("-------------------------------------------------------------")
        }
    }
    
    /*
     * start location scan
     */
    func updateDeviceLocation() {
        
        locationManager.delegate = self
        
        deviceLocationManager.checkForLocationAccess {
            
            switch self.locationFetchMode
            {
                case 1:
                
                    if self.locationFetchTrying { return }
                
                    self.locationFetchTrying = true
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    self.locationManager.activityType = .fitness
                    self.locationManager.distanceFilter = self.locationDistanceHook
                    self.locationFetchStartTime = nil
                
                    self.locationManager.startUpdatingLocation()
                
                case 2:
                
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    self.locationManager.requestLocation()
                
                default: break
            }
        }
    }
    
    /*
     * stop location scan
     */
    func locationFetchStop () {
        
        locationManager.stopUpdatingLocation()
        locationFetchStartTime = nil
        locationFetchTrying = false
    }
    
    func locationManager(
       _ manager: CLLocationManager,
         didChangeAuthorization status: CLAuthorizationStatus) {
        
        if debugMode { print("locationManager: permission/authorization mode changed -> \(status.rawValue)") }
        
        switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                 deviceLocationManager.doThisWhenAuthorized?()
                 deviceLocationManager.doThisWhenAuthorized = nil
            
            default: break
        }
    }
    
    /*
     * error handling of location fetch using corresponding delegate call of locationManager
     */
    func locationManager(
       _ manager: CLLocationManager,
         didFailWithError error: Error) {
        
        if debugMode { print("locationManager: localization request finally failed -> \(error)") }
        
        locationFetchSuccess = false
        locationFetchStop()
    }
    
    /*
     * fetch current device location using corresponding delegate call of locationManager
     */
    func locationManager(
       _ manager: CLLocationManager,
         didUpdateLocations locations: [CLLocation]) {
        
        let _location = locations.last!
        let _coordinate = _location.coordinate
        
        switch locationFetchMode
        {
            case 1:
            
                let _accuracy = _location.horizontalAccuracy
                let _determinationTime = _location.timestamp
            
                // ignore first attempt
                if locationFetchStartTime == nil {
                    locationFetchStartTime = Date()
                
                    return
                }
            
                // ignore overtime requests
                if _determinationTime.timeIntervalSince(self.locationFetchStartTime) > locationCheckTimeout {
                    locationFetchStop()
                
                    return
                }
            
                // wait for the next one
                if _accuracy < 0 || _accuracy > locationAccuracy { return }
            
                locationFetchStop()
                updateCurrentLocationMeta(_coordinate)
            
            case 2:
            
                updateCurrentLocationMeta(_coordinate)
            
            default: break
        }
    }
}
