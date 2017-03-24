//
//  PageSetProfileViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 17.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit
import MapKit

extension PageSetProfileViewController: UIPageViewControllerDelegate {

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
        var _currentDeviceLocation: DeviceLocation?
        var _longitude: Double?
        var _latitude: Double?
        
        // device based location denied or no device location persisted yet?
        if appDelegate.useCurrentDeviceLocation == false || _currentDeviceLocations.count == 0 {
            let newCoords = mapView.centerCoordinate
            _latitude = newCoords.latitude
            _longitude = newCoords.longitude
        }
        
        // device based location fetch wanted and device location persisted?
        if appDelegate.useCurrentDeviceLocation == true && _currentDeviceLocations.count > 0 {
            _currentDeviceLocation = _currentDeviceLocations.first
            _longitude = _currentDeviceLocation!.longitude
            _latitude = _currentDeviceLocation!.latitude
        }
        
        getStudentMetaProfile(sessionUdacity.accountKey, _latitude, _longitude) { (success, error, studentData) in
        
            if success == true {
                completionHandlerForValidateData(true, nil, studentData)
            } else {
                completionHandlerForValidateData(false, error, nil)
            }
        }
    }
    
    /*
     * get students profile as NSDictionary block, used later as json body content
     * for our upsert parse client method.
     */
    private func getStudentMetaProfile(
        _ _accountKey: String!,
        _ _latitude: Double!,
        _ _longitude: Double!,
        
        _ completionHandlerForStudentMetaProfile: @escaping (
        _ success: Bool?,
        _ error: String?,
        _ studentData: PRSStudentData?) -> Void) {
    
        let _geocoder = CLGeocoder()
        let _location = CLLocation(latitude: _latitude!, longitude: _longitude!)
        var _mapString: String?
        
        _geocoder.reverseGeocodeLocation(_location) { (placemarks, error) in
            _mapString = self.getMapPlacemarkAsString(withPlacemarks: placemarks, error: error) ?? self.metaNoData
            let currentStudentDict : NSDictionary =
                [
                    "uniqueKey" : _accountKey!,
                    "firstName" : self.inpFirstname.text! as String,
                    "lastName"  : self.inpLastname.text! as String,
                    "mediaURL"  : self.inpMediaURL.text! as String,
                    "latitude"  : _latitude! as Double,
                    "longitude" : _longitude! as Double,
                    "mapString" : _mapString! as String,
                ]
            
            completionHandlerForStudentMetaProfile(true, nil, PRSStudentData(currentStudentDict))
        }
    }
    
    /*
     * tranlate current map coordinate based placemark to a human readable location string
     * try to render a compactAddress using my own CLPlacemark extension fallback (a) to city
     * name on any nil-return, fallback (b) return nil
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
    
    //
    // MARK: Delegates
    //
}
