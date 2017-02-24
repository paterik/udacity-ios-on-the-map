//
//  RequestClientExtension.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 13.01.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import Foundation

extension RequestClient {
    
    /*
     * base GET method for our request base client
     */
    func get (
        _ url: String,
          headers: [String:String],
          completionHandlerForGet: @escaping (_ data: AnyObject?, _ errorString: String?)
        -> Void) {
        
        requestExecute(
            requestPrepare(url, "GET", headers: headers, jsonDataBody:[:]),
            completionHandlerForRequest: completionHandlerForGet
        )
    }
    
    /*
     * base POST method for our request base client
     */
    func post (
        _ url: String,
          headers: [String:String],
          completionHandlerForPost: @escaping (_ data: AnyObject?, _ errorString: String?)
        -> Void) {
        
        requestExecute(
            requestPrepare(url, "POST", headers: headers, jsonDataBody:[:]),
            completionHandlerForRequest: completionHandlerForPost
        )
    }
    
    /*
     * base PUT method for our request base client
     */
    func put (
        _ url: String,
          headers: [String:String],
          completionHandlerForPut: @escaping (_ data: AnyObject?, _ errorString: String?)
        -> Void) {
        
        requestExecute(
            requestPrepare(url, "PUT", headers: headers, jsonDataBody:[:]),
            completionHandlerForRequest: completionHandlerForPut
        )
    }
    
    /*
     * base PATCH method for our request base client
     */
    func patch (
        _ url: String,
          headers: [String:String],
          completionHandlerForPatch: @escaping (_ data: AnyObject?, _ errorString: String?) -> Void) {
        
        requestExecute(
            requestPrepare(url, "PATCH", headers: headers, jsonDataBody:[:]),
            completionHandlerForRequest: completionHandlerForPatch
        )
    }
    
    /* 
     * take a raw JSON NSData object and return a (real) usable foundation object 
     */
    func convertDataWithCompletionHandler(
        data: NSData,
        completionHandlerForConvertData: (_ result: Any?, _ errorString: String?) -> Void) {
        
        var parsedResult: Any!
        
        do {
            
            parsedResult = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments)
            
        } catch {
            
            completionHandlerForConvertData(nil, "Up's, could not parse the data as JSON: '\(data)'")
            
            if self.debugMode {
                print(error)
            }
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
}