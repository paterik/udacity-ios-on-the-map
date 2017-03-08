//
//  RequestBaseClient.swift
//  OnTheMap
//
//  ClassMethod(s)
//
//  - func requestPossible () -> Bool       :: check request/network connection
//  - func requestPrepare  () -> URLRequest :: prepare global request object for upcoming request
//  - func requestExecute  () -> [void]     :: execute the prepared base request used for helper methods (get, post, patch ...)
//
//
//  Extension(s)
//
//  - func convertDataWithCompletionHandler :: special json converter / completion handler for handling json results
//
//  Created by Patrick Paechnatz on 31.12.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import Foundation
import SystemConfiguration

class RequestClient {
    
    //
    // MARK: Constants (Statics)
    //
    static let sharedInstance = RequestClient()
    
    //
    // MARK: Constants (Normal)
    //
    let debugMode: Bool = true
    let session = URLSession.shared
    let _udcApiSkipCharCount: Int = 5
    let _udcApiIdentUrls: [String] = ["https://www.udacity.com/api/session"]
    let _httpVerbsWrite: [String] = ["POST", "PUT", "PATCH", "DELETE"]
    let _httpVerbsRead: [String] = ["OPTIONS", "GET", "HEAD", "TRACE"]
    
    //
    // MARK: Properties
    //
    var username: String?
    var password: String?
    var jsonBody: String = "{}"
    var errorDomain: String = ""
    var errorDomainPrefix: String = "APPClient"
    var errorUserInfo: [String: String] = ["" : ""]
    var isUdacityRequest: Bool! = false
    
    /**
     * check network reachability and connection state of current device
     */
    func requestPossible () -> Bool {
    
        var zeroAddress = sockaddr_in()
        var flags = SCNetworkReachabilityFlags()
        
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection)
    }
    
    /*
     * prepare the main request for all api calls within this app, cache will be disabled,
     * standard cahrsat will be utf-8 and we'll always await json as response type. If any
     * none-idempotent http verb will found, application/json will be set as body/data-type
     */
    func requestPrepare (
        _ url: String,
        _ method: String,
          headers: [String : String],
          jsonDataBody: [String : AnyObject]?)
        
        -> URLRequest {
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        
        request.addValue("UTF-8", forHTTPHeaderField: "Accept-Charset")
        request.addValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
            
        if _httpVerbsWrite.contains(method.uppercased()) {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        request.httpMethod = method
        
        /* identify udacity url requests and tag them as such 'special' request */
        if _udcApiIdentUrls.contains(url) {
            isUdacityRequest = true
        }
        
        /* extend header by defined parametric values */
        if !headers.isEmpty {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        /* body dictionary data not empty? Handle this data as json-compatible type */
        if !(jsonDataBody?.values.isEmpty)! {
            
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
    
    /*
     * execute the main request process and handle result using lambda completion handler.
     * we'll use another completionHandler (convertDataWithCompletionHandler) to convert json results
     */
    func requestExecute (
         _ request: URLRequest,
           completionHandlerForRequest: @escaping (_ data: AnyObject?, _ errorString: String?)
        
        -> Void) {
        
        /* check connection availability and execute request process */
        if false == requestPossible() {
        
            completionHandlerForRequest(nil, "Device not connected to the internet, check your connection state!")
            
        } else {
            
            print("-------------")
            print(request.allHTTPHeaderFields!)
            // print(NSString(data: request.httpBody!, encoding:String.Encoding.utf8.rawValue)!)
            print("-------------")
            
            let task = session.dataTask(with: request as URLRequest) { data, response, error in
                
                var parsedResult: Any!
                var newData: Data!
                
                /* our internal error logging method */
                func sendError(error: String) {
                    
                    completionHandlerForRequest(nil, error)
                    if self.debugMode {
                        print(error)
                    }
                }
                
                /* GUARD: Was there an error? */
                guard error == nil else {
                    sendError(error: "Up's, there was an error with your request: \(error)")
                    return
                }
                
                /* GUARD: Was there any data returned? */
                guard let data = data else {
                    sendError(error: "Up's, no data was returned by your request!")
                    return
                }
                
                /* UNWRAP: http status code available? */
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    
                    if statusCode == 403 {
                        sendError(error: "Up's, the account was not found or invalid credentials provided!")
                        return
                    }
                    
                    /* sometimes status code 400 returned, we've to check what kind of error this code is involved with */
                    if (statusCode == 400 || statusCode == 404) || (statusCode >= 500 && statusCode <= 599) {
                        
                        sendError(error: "Up's, your request returned a status code other than 2xx or 403! A service downtime may possible :(")
                        if self.debugMode {
                            print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
                        }
                        
                        return
                    }
                }

                newData = data
                if true == self.isUdacityRequest {
                    newData = data.subdata(in: Range(uncheckedBounds: (self._udcApiSkipCharCount, data.count)))
                }
                
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: newData as Data, options: .allowFragments)
                } catch {
                    completionHandlerForRequest(nil, "Up's, could not parse the data as JSON: '\(data)'")
                    if self.debugMode {
                        print(error)
                    }
                    
                    return
                }
            
                completionHandlerForRequest(parsedResult as AnyObject?, nil)
                
            }
            
            /* Finaly start the corresponding request */
            task.resume()
        }
    }
}
