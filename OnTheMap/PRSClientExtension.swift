//
//  PRSClientExtension.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 31.12.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import Foundation
import MapKit
import UIKit

extension PRSClient {

    /*
     * prepare student data object for upcoming patch/put request remove 'createdAt' key
     */
    func prepareStudentMetaForPutRequest(
       _ studentData: PRSStudentData?) -> [String : AnyObject]? {
        
        var studentDataArray = studentData!.asArray
        
        if let index = studentDataArray.index(forKey: "createdAt") {
            studentDataArray.remove(at: index)
        }
        
        return studentDataArray as [String : AnyObject]?
    }
    
    /*
     * prepare student data object for upcoming post request remove redundant 'objectId' key
     */
    func prepareStudentMetaForPostRequest(
       _ studentData: PRSStudentData?) -> [String : AnyObject]? {
        
        var studentDataArray = studentData!.asArray
        if let index = studentDataArray.index(forKey: "objectId") {
            studentDataArray.remove(at: index)
        }
        
        return studentDataArray as [String : AnyObject]?
    }
    
    /*
     * return json string from array
     */
    func getJSONFromStringArray(
       _ arrayData: [String:String]) -> String {
        
        var JSONString: String = "{}"
        
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: arrayData, options: JSONSerialization.WritingOptions.prettyPrinted)
            if let _jsonString = String(data: jsonData, encoding: String.Encoding.utf8) { JSONString = _jsonString }
            
        } catch {
            
            if debugMode { print ("An Error occured in ParseClient::getJSONFromStringArray -> \(error)") }
        
        }
        
        return JSONString
    }
    
    /**
     * return json string from student meta dictionary
     */
    func getJSONFromStudentMetaDictionary(
       _ studentData: PRSStudentData!) -> String {
        
        var JSONString: String = "{}"
        
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: studentData, options: JSONSerialization.WritingOptions.prettyPrinted)
            if let _jsonString = String(data: jsonData, encoding: String.Encoding.utf8) { JSONString = _jsonString }
            
        } catch {
            if debugMode { print ("An Error occured in ParseClient::getJSONFromStringArray -> \(error)") }
        }
        
        return JSONString
    }
    
    /*
     * add further meta information to our customer mota object using google maps api by delayed requests of 250ms
     */
    func enrichStudentMeta() {
        
        students.clearValidatorCache()
        
        for (index, meta) in students.locations.enumerated() {
        
            if self.validateStudentMeta(meta) == true {
            
                // try to evaluate cached response/result instead of using an "expensive" google api call first
                self.clientGoogle.getMapMetaByCache(meta.longitude!, meta.latitude!) {
                    
                    (success, message, gClientSession) in
                    
                    if success == true {
                        
                        self.students.locations[index].flag = self.getFlagByCountryISOCode(gClientSession!.countryCode!)
                        self.students.locations[index].country = gClientSession!.countryName ?? self.metaCountryUnknown
                        if self.debugMode { print ("_ fetch cached flag \(self.students.locations[index].flag)") }
                        
                    } else {
                        
                        // call googles map api using dispatch queue command pipe including a 250ms delay to prevent "OVER_QUERY_LIMIT"
                        DispatchQueue.main.asyncAfter(deadline: .now() + (Double(index) / 4 )) {
                            
                            self.clientGoogle.getMapMetaByCoordinates(meta.longitude!, meta.latitude!) {
                                
                                (success, message, gClientSession) in
                                
                                if success == true {
                                    
                                    self.students.locations[index].flag = self.getFlagByCountryISOCode(gClientSession!.countryCode!)
                                    self.students.locations[index].country = gClientSession!.countryName ?? self.metaCountryUnknown
                                    if self.debugMode { print ("_ fetch frech flag  \(self.students.locations[index].flag)") }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /*
     * validate incoming student meta lines check for valid geo localization properties, return false if
     * coordinates seems invalid (using regex validation process), uniqueKey and objectId are missing or
     * objectId/uniqueId already stored in collection
     */
    func validateStudentMeta(
       _ meta:PRSStudentData) -> Bool {
        
        var isValid: Bool = false
        
        guard let _latitudeRaw = meta.latitude,
              let _longitudeRaw = meta.longitude,
              let _objectId = meta.objectId,
              let _uniqueKey = meta.uniqueKey else {
            
            return isValid
        }
        
        let _latitude: String = String(format:"%f", _latitudeRaw)
        let _longitude: String = String(format:"%f", _longitudeRaw)
        let _latitudeRegex = "^(\\+|-)?(?:90(?:(?:\\.0{1,6})?)|(?:[0-9]|[1-8][0-9])(?:(?:\\.[0-9]{1,6})?))$"
        let _longitudeRegex = "^(\\+|-)?(?:180(?:(?:\\.0{1,6})?)|(?:[0-9]|[1-9][0-9]|1[0-7][0-9])(?:(?:\\.[0-9]{1,6})?))$"
        
        if (_longitude.range(of: _longitudeRegex, options: .regularExpression) != nil &&
            _latitude.range(of: _latitudeRegex, options: .regularExpression) != nil &&
            _uniqueKey != "" && _objectId != "" &&
             students.locationObjectIds.contains(_objectId) == false &&
             students.locationUniqueKeys.contains(_uniqueKey) == false) {
            
            isValid = true
        }
        
        students.locationObjectIds.append(meta.objectId)
        students.locationUniqueKeys.append(meta.uniqueKey)
        
        return isValid
    }
    
    /*
     * get a emoji flag by given country iso-code, return "🏴" on invalid/unknown code
     */
    func getFlagByCountryISOCode(
        _ code: String) -> String {
        
        for localeISOCode in NSLocale.isoCountryCodes {
            
            if code == localeISOCode {
                return code.unicodeScalars.flatMap { String.init(UnicodeScalar(127397 + $0.value)!) }.joined()
            }
        }
        
        return metaCountryUnknownFlag
    }
}
