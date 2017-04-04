//
//  PRSClientExtension.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 31.12.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import UIKit
import MapKit
import CryptoSwift

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
     * get the longest distance to another student locations using simpleSort
     */
    func getLongestDistanceOfStudentMeta() -> Double {
        
        var _largestDistance: Double = 0.0
        
        for meta in students.locations {
        
            // ignore hidden and distance free location objects
            if meta.isHidden == true || meta.distance.isEmpty == true {
                continue
            }
            
            if meta.distanceValue > _largestDistance {
                _largestDistance = meta.distanceValue
            }
        }
        
        return _largestDistance
    }
    
    /*
     * get the numver of countries from all student locations
     */
    func getNumberOfCountriesFromStudentMeta() -> Int {
        
        var _allCountries: [String] = [""]
        
        if students.locations.count == 0 { return 0 }
        
        for meta in students.locations {
            
            // ignore hidden and country free location objects
            if meta.isHidden == true || meta.country.isEmpty == true {
                continue
            }
            
            _allCountries.append(meta.country)
        }
        
        return Array(Set(_allCountries)).count
    }
    
    /*
     * add further meta information to our customer mota object using google maps api by delayed requests (e.g. 100ms)
     * this method is growen up to more lines than expected, I'll refactor this one in my upcoming release 1.0.n
     */
    func enrichStudentMeta() {
        
        for (idx, meta) in students.locations.enumerated() {
            
            // ignore hidden location object
            if meta.isHidden == true {
                continue
            }
            
            // 1st try to evaluate cached response/result instead of using an "expensive" Google/iOS api calls first
            self.clientGoogle.getMapMetaByCache(meta.longitude!, meta.latitude!) {
                    
                (success, message, gClientSession) in

                if success == true {
                    
                    if let index = self.students.findIndexByObjectId( meta.objectId ) {
                    
                        self.students.locations[index].flag = gClientSession!.countryCode!.getFlagByCountryISOCode()
                        self.students.locations[index].country = gClientSession!.countryName ?? self.metaCountryUnknown
                        if self.debugMode {
                            print ("_ fetch cached flag for index \(index): \(self.students.locations[index].flag)")
                        }
                    }
                    
                } else {
                    
                    if self.appDelegate.forceQueueExit == false {
                    
                        //
                        // add our final request as process within an execution call timer set of 250ms to main operation
                        // queue asynchronously to prevent api threshold limitiation of google and iOS.
                        //
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + (Double(idx) / 10 )) {
                            
                            // 2nd - try to fetch meta information using ios internal reverse geolocation handler
                            self.clientGoogle.getMapMetaByReverseGeocodeLocation(meta.longitude!, meta.latitude!) {
                                
                                (success, message, gClientSession) in
                                
                                if success == true {
                                    
                                    //
                                    // problem: if one location was removed during runtime of this task
                                    // the queue manager will crash with out-of-index message ... (sad)
                                    //
                                    
                                    if let index = self.students.findIndexByObjectId( meta.objectId ) {
                                        
                                        self.students.locations[index].flag = gClientSession!.countryCode!.getFlagByCountryISOCode()
                                        self.students.locations[index].country = gClientSession!.countryName ?? self.metaCountryUnknown
                                    
                                        if self.debugMode {
                                            print ("_ fetch intern flag for index \(index): \(self.students.locations[index].flag)")
                                        }
                                    }
                                    
                                } else {
                                    
                                    // 3rd - try to fetch the required meta information using public google api service
                                    self.clientGoogle.getMapMetaByCoordinates(meta.longitude!, meta.latitude!) {
                                        
                                        (success, message, gClientSession) in
                                        
                                        if success == true {
                                            
                                            if let index = self.students.findIndexByObjectId( meta.objectId ) {
                                                
                                                self.students.locations[index].flag = gClientSession!.countryCode!.getFlagByCountryISOCode()
                                                self.students.locations[index].country = gClientSession!.countryName ?? self.metaCountryUnknown
                                                if self.debugMode {
                                                    print ("_ fetch new flag for index \(index): \(self.students.locations[index].flag)")
                                                }
                                            }
                                            
                                        } else {
                                            
                                            if let index = self.students.findIndexByObjectId( meta.objectId ) {
                                            
                                                // 4th - evaluate location meta block as default "unknown" try to set fallback values
                                                var country = self.students.locations[index].mapString!
                                                if  country.isEmpty {
                                                    country = self.metaCountryUnknown
                                                }
                                                
                                                self.students.locations[index].country = country
                                                self.students.locations[index].flag = self.metaCountryUnknownFlag
                                                if self.debugMode {
                                                    print ("_ unable to fetch flag! Error: \(String(describing: message))")
                                                }
                                            }
                                        }
                                    }
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
     * coordinates seems invalid (using regex validation process). Finally generate a hashed position key
     * to prevent double equal-location entries in map-annotation and corresponding listView.
     */
    func validateStudentMeta(
       _ meta:PRSStudentData) -> Bool {
        
        var isValid: Bool = false
        
        if meta.isHidden == true { return isValid }

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
        let _positionKey = getHashedPositionKey(_longitude, _latitude, _uniqueKey)
        
        if (_longitude.range(of: _longitudeRegex, options: .regularExpression) != nil &&
            _latitude.range(of: _latitudeRegex, options: .regularExpression) != nil &&
            _uniqueKey.isEmpty == false && _objectId.isEmpty == false &&
             students.locationObjectIds.contains(_objectId) == false &&
             students.locationCoordinateKeys.contains(_positionKey) == false) {
            
            isValid = true
        }
        
        students.locationObjectIds.append(meta.objectId)
        students.locationUniqueKeys.append(meta.uniqueKey)
        students.locationCoordinateKeys.append(_positionKey)
        
        return isValid
    }
    
    /*
     * generate a dummy location as first entry to be overriden by statistic cell
     */
    func addIndexZeroStudentLocation() -> Void {
        
        let dummyStudentDict : NSDictionary = [:]
        var dummyStudentMeta = PRSStudentData(dummyStudentDict)
            dummyStudentMeta.isHidden = true
        
        self.students.locations.append(dummyStudentMeta)
        self.students.myLocations.append(dummyStudentMeta)
    }
    
    /*
     * get a hashed position key hash(longitude,latitude,uniqueKey) for each student position used as
     * unique identifier to prevent rendering of multiple (identical) positions
     */
    private func getHashedPositionKey(_ longitude: String, _ latitude: String, _ uniqueKey: String) -> String {
        
        let _positionKey = NSString(
             format: "%@|%@|%@",
             longitude,
             latitude,
             uniqueKey) as String
        
        let _bytes = Array(_positionKey.utf8)
        
        return _bytes.sha224().toHexString()
    }
}
