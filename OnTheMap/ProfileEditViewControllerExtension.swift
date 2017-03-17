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
        
        if inpFirstname.text?.isEmpty ?? true && inpLastname.text?.isEmpty ?? true {
            
            completionHandlerForValidateData(false, "Up's, validation for your user profile failed! Check your firstname/lastname!", nil)
        }
        
        // let currentDeviceLocation: MapViewLocation = currentDeviceLocations.first!
        print (ProfileEditViewController.appDelegate.currentDeviceLocations)
        
        let currentStudentDict : NSDictionary =
            [
                "firstName": inpFirstname.text!,
                "lastName": inpLastname.text!,
                "mediaURL": inpMediaURL.text!,
                "mapString": "test123",
                "latitude": 51.05089,
                "longitude": 13.73832,
            ]
        
        completionHandlerForValidateData(true, nil, PRSStudentData(currentStudentDict))
    }
}
