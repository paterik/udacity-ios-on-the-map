//
//  PRSClientExtension.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 31.12.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import Foundation

extension PRSClient {

    /*
     * validate incoming student meta lines check for valid geo localization properties, return false if
     * coordinates seems invalid (using regex call)
     */
    func validateStudentMeta(_ meta:PRSStudentData) -> Bool {
        
        guard let _latitudeRaw = meta.latitude,
              let _longitudeRaw = meta.longitude else {
            
            return false
        }
        
        let _latitude: String = String(format:"%f", _latitudeRaw)
        let _longitude: String = String(format:"%f", _longitudeRaw)
        let _latitudeRegex = "^(\\+|-)?(?:90(?:(?:\\.0{1,6})?)|(?:[0-9]|[1-8][0-9])(?:(?:\\.[0-9]{1,6})?))$"
        let _longitudeRegex = "^(\\+|-)?(?:180(?:(?:\\.0{1,6})?)|(?:[0-9]|[1-9][0-9]|1[0-7][0-9])(?:(?:\\.[0-9]{1,6})?))$"
        
        var isValid: Bool = false
        
        if (_longitude.range(of: _longitudeRegex, options: .regularExpression) != nil &&
            _latitude.range(of: _latitudeRegex, options: .regularExpression) != nil) {
            
            isValid = true
        }
        
        return isValid
    }
}
