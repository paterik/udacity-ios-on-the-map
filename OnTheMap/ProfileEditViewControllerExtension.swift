//
//  ProfileEditViewControllerExtension.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 17.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import Foundation
import UIKit

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
        var _currentDeviceLocation: DeviceLocation?
        var _longitude: Double?
        var _latitude: Double?
        
        if useCurrentDeviceLocation == true && _currentDeviceLocations.count > 0 {
            _currentDeviceLocation = _currentDeviceLocations.first
            _longitude = _currentDeviceLocation!.longitude
            _latitude = _currentDeviceLocation!.latitude
        }
        
        let currentStudentDict : NSDictionary =
            [
                "firstName" : inpFirstname.text! as String,
                "lastName"  : inpLastname.text! as String,
                "mediaURL"  : inpMediaURL.text! as String,
                "mapString" : "Dresden, Germany" as String,
                "uniqueKey" : sessionUdacity.accountKey!,
                "latitude"  : _latitude! as Double,
                "longitude" : _longitude! as Double,
            ]
        
        completionHandlerForValidateData(true, nil, PRSStudentData(currentStudentDict))
    }
}
