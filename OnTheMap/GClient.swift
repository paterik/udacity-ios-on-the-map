//
//  GClient.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 31.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import Foundation
import MapKit

class GClient: NSObject {

    //
    // MARK: Constants (Statics)
    //
    
    static let sharedInstance = GClient()
    
    //
    // MARK: Constants (Normal)
    //
    
    let debugMode: Bool = true
    let session = URLSession.shared
    let client = RequestClient.sharedInstance
    let dateFormatter = DateFormatter()
    
    //
    // MARK: Constants (API)
    //
    
    let apiURL: String = "https://maps.googleapis.com/maps/api/geocode/json"
    
    //
    // MARK: Variables
    //
    
    lazy var geoCoder = CLGeocoder()
    
    //
    // MARK: Methods (Public)
    //
    
    /*
     * get map meta data (as google session object) using cache layer (collection)
     */
    func getMapMetaByCache (
       _ longitude: Double,
       _ latitude: Double,
       
         completionHandlerGetMapMetaFromCache: @escaping (
       _ success: Bool?,
       _ message: String?,
       _ gClientSession: GClientSession?)
        
        -> Void) {
        
        // try to use cache first!
        for cache in GClientCache.sharedInstance.metaData {
            
            if "\(latitude),\(longitude)" == cache.cacheApiRequestParam {
                completionHandlerGetMapMetaFromCache(true, nil, cache)
                
                return
            }
        }
        
        completionHandlerGetMapMetaFromCache(false, "no entry for \(latitude),\(longitude) in cached requests found ...", nil)
    }
    
    /*
     * get map meta data (as google session object) using iOS API internals (reverseGeocodeLocation)
     */
    func getMapMetaByReverseGeocodeLocation(
       _ longitude: Double,
       _ latitude: Double,
       _ completionHandlerGetMapMeta: @escaping (
       _ success: Bool?,
       _ message: String?,
       _ gClientSession: GClientSession?) -> Void) {
        
        
        // add protective cache-call logic to prevent api-requests by calling this method natively
        getMapMetaByCache(longitude, latitude) {
            
            (success, message, gClientSession) in
            
            if success == true {
                completionHandlerGetMapMeta(true, nil , gClientSession)
                return
            }
        }
        
        geoCoder.reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) {
            
            (placemarks, error) -> Void in
            
            if error != nil {
                
                completionHandlerGetMapMeta(
                    false, "Up's, reverse geocode location couldn't be handled ... \(String(describing: error))", nil
                )
            
            } else {
            
                if let placemarks = placemarks,
                   let placemark = placemarks.first,
                   let isoCountryCode = placemark.isoCountryCode,
                   let country = placemark.country {
                    
                    
                    let _gClientSession = GClientSession(
                        
                        cacheApiRequestURL: nil,
                        cacheApiRequestParam: "\(latitude),\(longitude)",
                        cacheApiRequestDate: Date(),
                        
                        countryName: country,
                        countryCode: isoCountryCode
                    )
                    
                    GClientCache.sharedInstance.metaData.append(_gClientSession)
                    completionHandlerGetMapMeta(true, nil , _gClientSession)
                    
                } else {
                    
                    completionHandlerGetMapMeta(false, "Up's, unable to read results of reverse geocode location", nil)
                    
                }
            }
        }
    }
    
    /*
     * get additional meta information using googles map api, evaluating country name and country iso code for flag
     * emoji extension of student data. I've including caching "logic" to prevent double calls for location coord's
     * who where fetched earlier.
     */
    func getMapMetaByCoordinates (
        _ longitude: Double,
        _ latitude: Double,
        
          completionHandlerGetMapMeta: @escaping (
        _ success: Bool?,
        _ message: String?,
        _ gClientSession: GClientSession?)
        
        -> Void) {
        
        // also add protective cache-call logic to prevent api-requests by calling this method natively
        getMapMetaByCache(longitude, latitude) {
            
            (success, message, gClientSession) in
            
            if success == true {
                completionHandlerGetMapMeta(true, nil , gClientSession)
                return
            }
        }
        
        let apiRequestURL = NSString(format: "%@?latlng=%@&sensor=true_or_false", apiURL, "\(latitude),\(longitude)")
        
        client.get(apiRequestURL as String, headers: [:])
        {
            (data, error) in
         
            if (error != nil) {
                completionHandlerGetMapMeta(false, "Up's, your request couldn't be handled ... \(String(describing: error))", nil)
                
            } else {
                
                guard let results = data!["results"] as? [[String: AnyObject]] else {
                    completionHandlerGetMapMeta(false, "Up's, missing result key in response data", nil)
                    return
                }
                
                guard let status = data!["status"] as? String else {
                    completionHandlerGetMapMeta(false, "Up's, missing status key in response data", nil)
                    return
                }
                
                if status == "OK" && results.count > 0 {
                    
                    let countryComponents = results[ results.count-1 ]
                    if let countryAddressComponents = countryComponents[ "address_components" ] as? NSArray {
                        
                        var addressComponent = countryAddressComponents[ 0 ] as! NSDictionary
                        if countryAddressComponents.count > 1 {
                            addressComponent = countryAddressComponents[ countryAddressComponents.count-1 ] as! NSDictionary
                        }
                        
                        let _gClientSession = GClientSession(
                            
                            cacheApiRequestURL: apiRequestURL as String,
                            cacheApiRequestParam: "\(latitude),\(longitude)",
                            cacheApiRequestDate: Date(),
                            
                            countryName: addressComponent["long_name"] as! String,
                            countryCode: addressComponent["short_name"] as! String
                        )
                        
                        GClientCache.sharedInstance.metaData.append(_gClientSession)
                        
                        completionHandlerGetMapMeta(true, nil , _gClientSession)
                    }
                    
                } else {
                    
                    completionHandlerGetMapMeta(
                        false, "Up's, couldn't foind any plausible data for \(latitude),\(longitude) -> status=\(status)", nil
                    )
                }
            }
        }
    }
}
