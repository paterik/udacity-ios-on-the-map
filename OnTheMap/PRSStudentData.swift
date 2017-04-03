//
//  PRSStudentData.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 27.12.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import Foundation

struct PRSStudentData {
    
    let uniqueKey: String!
    
    let firstName: String!
    let lastName: String!
    let mapString: String!
    let mediaURL: String!
    
    let latitude: Double?
    let longitude: Double?
    
    let createdAt: Date!
    let updatedAt: Date!
    
    var objectId: String!
    var _createdAtRaw: NSString!
    var _updatedAtRaw: NSString!
    
    private var _distance: String = ""
    private var _distanceValue: Double = 0.0
    private var _country: String = ""
    private var _flag: String = ""
    private var _isHidden: Bool = false
    
    public var distance: String {
        get { return self._distance }
        set { self._distance = newValue }
    }
    
    public var distanceValue: Double {
        get { return self._distanceValue }
        set { self._distanceValue = newValue }
    }
    
    public var country: String {
        get { return self._country }
        set { self._country = newValue }
    }
    
    public var flag: String {
        get { return self._flag }
        set { self._flag = newValue }
    }
    
    public var isHidden: Bool {
        get { return self._isHidden }
        set { self._isHidden = newValue }
    }
    
    var asArray: [String : Any] {
        
        get {
            return [
                "firstName" : firstName  ?? "",
                "lastName"  : lastName   ?? "",
                "mediaURL"  : mediaURL   ?? "",
                "mapString" : mapString  ?? "",
                "objectId"  : objectId   ?? "",
                "uniqueKey" : uniqueKey  ?? "",
                "latitude"  : latitude!  as Double,
                "longitude" : longitude! as Double,
                "createdAt" : ["__type" : "Date", "iso" : _createdAtRaw ],
                "updatedAt" : ["__type" : "Date", "iso" : _updatedAtRaw ]
                
            ] as [String : Any]
        }
    }
    
    init (_ dictionary: NSDictionary) {
        
        //
        // prepare incomming student meta data, write defaults for
        // nil or unwrappable properties and add an evalation date
        //
        
        _createdAtRaw = NSDate().dateToString(Date(), PRSClient.sharedInstance.metaDateTimeFormat)
        _updatedAtRaw = NSDate().dateToString(Date(), PRSClient.sharedInstance.metaDateTimeFormat)
        
        if dictionary["createdAt"] != nil {
             _createdAtRaw = (dictionary["createdAt"] as? NSString)!
        }
        
        if dictionary["updateAt"] != nil {
             _updatedAtRaw = (dictionary["updatedAt"] as? NSString)!
        }
        
        firstName = (dictionary["firstName"] as? String!) ?? ""
        lastName  = (dictionary["lastName"] as? String!)  ?? ""
        mediaURL  = (dictionary["mediaURL"] as? String!)  ?? ""
        mapString = (dictionary["mapString"] as? String!) ?? ""
        objectId  = (dictionary["objectId"] as? String!)  ?? ""
        uniqueKey = (dictionary["uniqueKey"] as? String!) ?? ""

        latitude  = (dictionary["latitude"] as? Double!)  ?? 0.0
        longitude = (dictionary["longitude"] as? Double!) ?? 0.0

        createdAt = NSDate().dateFromString(_createdAtRaw, PRSClient.sharedInstance.metaDateTimeFormat) as Date!
        updatedAt = NSDate().dateFromString(_updatedAtRaw, PRSClient.sharedInstance.metaDateTimeFormat) as Date!
    }
}
