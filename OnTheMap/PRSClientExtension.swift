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
     * prepare student data object for upcoming patch/put request remove 'createdAt' key
     */
    func prepareStudentMetaForPutRequest(
       _ studentData: PRSStudentData?) -> [String : AnyObject]? {
        
        var studentDataArray = studentData!.asArray
            studentDataArray["objectId"] = appDelegate.currentUserStudentLocation?.objectId!
        
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
     * validate incoming student meta lines check for valid geo localization properties, return false if
     * coordinates seems invalid (using regex validation process)
     */
    func validateStudentMeta(
       _ meta:PRSStudentData) -> Bool {
        
        var isValid: Bool = false
        
        guard let _latitudeRaw = meta.latitude,
              let _longitudeRaw = meta.longitude else {
            
            return isValid
        }
        
        let _latitude: String = String(format:"%f", _latitudeRaw)
        let _longitude: String = String(format:"%f", _longitudeRaw)
        let _latitudeRegex = "^(\\+|-)?(?:90(?:(?:\\.0{1,6})?)|(?:[0-9]|[1-8][0-9])(?:(?:\\.[0-9]{1,6})?))$"
        let _longitudeRegex = "^(\\+|-)?(?:180(?:(?:\\.0{1,6})?)|(?:[0-9]|[1-9][0-9]|1[0-7][0-9])(?:(?:\\.[0-9]{1,6})?))$"
        
        if (_longitude.range(of: _longitudeRegex, options: .regularExpression) != nil &&
            _latitude.range(of: _latitudeRegex, options: .regularExpression) != nil) {
            
            isValid = true
        }
        
        return isValid
    }
}
