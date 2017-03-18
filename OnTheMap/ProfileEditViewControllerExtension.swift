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
        
        // check for vaild input fields (firstName and lastNAme)
        if inpFirstname.text?.isEmpty ?? true && inpLastname.text?.isEmpty ?? true {
            completionHandlerForValidateData(
                false, "Up's, validation for your user profile failed! Check your firstname/lastname!", nil
            )
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
                "firstName" : inpFirstname.text!,
                "lastName"  : inpLastname.text!,
                "mediaURL"  : inpMediaURL.text!,
                "mapString" : "test123",
                "latitude"  : _latitude!,
                "longitude" : _longitude!,
            ]
        
        completionHandlerForValidateData(true, nil, PRSStudentData(currentStudentDict))
    }
}
