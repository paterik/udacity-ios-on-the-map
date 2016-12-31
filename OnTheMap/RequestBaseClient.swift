//
//  RequestBaseClient.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 31.12.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import Foundation

class RequestBaseClient {
    
    //
    // MARK: Constants (Statics)
    //
    static let sharedInstance = RequestBaseClient()
    
    //
    // MARK: Constants (Normal)
    //
    let debugMode: Bool = true
    let session = URLSession.shared
    
    /* 
     prepare the main request for all api calls within this app, cache will be disabled,
     standard cahrsat will be utf-8 and we'll always await json as response type. If any
     none-idempotent http verb will found, application/json willbe set as body/data-type 
     */
    func prepareRequest (
        _ url: String,
        _ method: String,
        headers: [String : String],
        jsonDataBody: [String : AnyObject]?) -> URLRequest {
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        
        request.addValue("UTF-8", forHTTPHeaderField: "Accept-Charset")
        request.addValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if transportMethods.contains(method) {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        request.httpMethod = method
        
        if !headers.isEmpty {
            for (key, value) in headers {
                request.addValue(key, forHTTPHeaderField: value)
            }
        }
        
        /* body dictionary data not empty? Handle this data as json-compatible type */
        if !jsonDataBody?.values.flatten().isEmpty {
            
            if let requestBodyDictionary = jsonDataBody {
                
                /* try serialize incoming dictionary body data, set body to nil on any exception during conversion */
                let serializedData: Data?; do {
                    serializedData = try JSONSerialization.data(withJSONObject: requestBodyDictionary, options: [])
                } catch {
                    serializedData = nil
                }
                
                request.httpBody = serializedData
            }
        }
        
        return request as URLRequest
    }


}
