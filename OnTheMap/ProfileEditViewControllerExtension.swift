//
//  ProfileEditViewControllerExtension.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 17.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension ProfileEditViewController {

    func validateStudentMetaData(
        _ completionHandlerForValidateData: @escaping (
        _ success: Bool?,
        _ error: String?,
        _ studentData: PRSStudentData?) -> Void) {
        
        // check for vaild input fields (firstName and lastName), return on any error here
        if inpFirstname.text?.isEmpty ?? true && inpLastname.text?.isEmpty ?? true {
            
            completionHandlerForValidateData(
                false, "Up's, validation for your user profile failed! Check your firstname/lastname!", nil
            )
            
            return
        }
        
        // check current session state, also return on any problem here
        guard let sessionUdacity = clientUdacity.clientSession else {
            
            completionHandlerForValidateData(
                false, "Up's, no active udacity user session were found! Are you still logged in?", nil
            )
            
            return
        }
        
        let _currentDeviceLocations: [DeviceLocation] = appDelegate.currentDeviceLocations
        let _geocoder = CLGeocoder()
        var _currentDeviceLocation: DeviceLocation?
        var _longitude: Double?
        var _latitude: Double?
        var _mapString: String?
        
        // device based location denied or no device location persisted yet?
        if useCurrentDeviceLocation == false || _currentDeviceLocations.count == 0 {
            let newCoords = mapView.centerCoordinate
            _latitude = newCoords.latitude
            _longitude = newCoords.longitude
        }
        
        // device based location fetch wanted and device location persisted?
        if useCurrentDeviceLocation == true && _currentDeviceLocations.count > 0 {
            _currentDeviceLocation = _currentDeviceLocations.first
            _longitude = _currentDeviceLocation!.longitude
            _latitude = _currentDeviceLocation!.latitude
            
            let location = CLLocation(latitude: _latitude!, longitude: _longitude!)
            // fetch current location as mapString meta value
            _geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                _mapString = self.getMapPlacemarkAsString(withPlacemarks: placemarks, error: error)
                let currentStudentDict : NSDictionary =
                    [
                        "uniqueKey" : sessionUdacity.accountKey!,
                        "firstName" : self.inpFirstname.text! as String,
                        "lastName"  : self.inpLastname.text! as String,
                        "mediaURL"  : self.inpMediaURL.text! as String,
                        "latitude"  : _latitude! as Double,
                        "longitude" : _longitude! as Double,
                        "mapString" : _mapString ?? self.metaNoData as String,
                    ]
                
                completionHandlerForValidateData(true, nil, PRSStudentData(currentStudentDict))
            }
        }
    }
    
    private func getStudentMetaProfile(
        _ _accountKey: String!,
        _ _latitude: Double!,
        _ _longitude: Double!,
        
        _ completionHandlerForValidateData: @escaping (
        _ success: Bool?,
        _ error: String?,
        _ studentData: PRSStudentData?) -> Void) {
    
        let _geocoder = CLGeocoder()
        let _location = CLLocation(latitude: _latitude!, longitude: _longitude!)
        var _mapString: String?
        
        _geocoder.reverseGeocodeLocation(_location) { (placemarks, error) in
            _mapString = self.getMapPlacemarkAsString(withPlacemarks: placemarks, error: error)
            let currentStudentDict : NSDictionary =
                [
                    "uniqueKey" : _accountKey!,
                    "firstName" : self.inpFirstname.text! as String,
                    "lastName"  : self.inpLastname.text! as String,
                    "mediaURL"  : self.inpMediaURL.text! as String,
                    "latitude"  : _latitude! as Double,
                    "longitude" : _longitude! as Double,
                    "mapString" : _mapString ?? self.metaNoData as String,
                ]
            
            completionHandlerForValidateData(true, nil, PRSStudentData(currentStudentDict))
        }
    }
    
    /*
     * tranlate current map coordinate based placemark to a human readable location string
     */
    private func getMapPlacemarkAsString(
        withPlacemarks placemarks: [CLPlacemark]?,
        error: Error?) -> String? {
        
        if let _error = error {
            
            if debugMode == true { print("problem to reverse ceocode location (\(_error))") }
            
        } else {
            
            if let placemarks = placemarks, let placemark = placemarks.first {
                
                return placemark.compactAddress ?? placemark.locality
            }
        }
        
        return nil
    }
}
