//
//  UDCClient.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 22.11.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import Foundation

class UDCClient: NSObject {
    
    //
    // MARK: Constants
    //
    static let sharedInstance = UDCClient()
    
    let apiURL: String = "https://www.udacity.com/api/session"
    let apiSkipCharCount: Int = 5
    let debugMode: Bool = true
    let session = URLSession.shared
    let dateFormatter = DateFormatter()
    
    //
    // MARK: Properties
    //
    var username: String?
    var password: String?
    var jsonBody: String = "{}"
    var errorDomain: String = ""
    var errorDomainPrefix: String = "UDCClient"
    var errorUserInfo: [String: String] = ["" : ""]
    
    func taskForPOSTMethod(
        jsonBody: String,
        completionHandlerForPOST: @escaping (_ result: Any?, _ error: NSError?) -> Void) -> URLSessionDataTask {
    
        let request = NSMutableURLRequest(url: URL(string: apiURL)!)

        request.httpMethod = "POST"
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            func sendError(error: String) {
                
                self.errorDomain = "\(self.errorDomainPrefix)_convertDataWithCompletionHandler"
                self.errorUserInfo =  [NSLocalizedDescriptionKey : error]
                
                completionHandlerForPOST(nil, NSError(domain: self.errorDomain, code: 1, userInfo: self.errorUserInfo))
                
                if self.debugMode {
                    print(error)
                }
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError(error: "Up's, there was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError(error: "Up's, no data was returned by the request!")
                return
            }
            
            /* UNWRAP: http status code available? */
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
            
                if statusCode == 403 {
                    sendError(error: "Up's, the account was not found or invalid credentials provided!")
                    return
                }
                
                /* sometimes status code 400 returned, we've to check what kind of error this code is involved with */
                if statusCode == 400 || statusCode == 404 || statusCode == 500 {
                    sendError(error: "Up's, your request returned a status code other than 2xx or 403! A service downtime may possible :(")
                    if self.debugMode {
                        print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
                    }
                    
                    return
                }
            }
            
            let range = Range(uncheckedBounds: (self.apiSkipCharCount, data.count))
            let newData = data.subdata(in: range)
            
            /* now parse the data and use the data in completion handler */
            self.convertDataWithCompletionHandler(
                data: newData as NSData,
                completionHandlerForConvertData: completionHandlerForPOST
            )
        }
        
        /* Finaly start the corresponding request */
        task.resume()
        
        return task
    }
    
    // take a raw JSON NSData object and return a (real) usable foundation object
    private func convertDataWithCompletionHandler(
        data: NSData,
        completionHandlerForConvertData: (_ result: Any?, _ error: NSError?) -> Void) {
        
        var parsedResult: Any!
        
        do {
            
            parsedResult = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments)
            
        } catch {
            
            errorDomain = "\(self.errorDomainPrefix)_convertDataWithCompletionHandler"
            errorUserInfo = [NSLocalizedDescriptionKey : "Up's, could not parse the data as JSON: '\(data)'"]
            
            completionHandlerForConvertData(nil, NSError(domain: errorDomain, code: 1, userInfo: errorUserInfo))
            
            if self.debugMode {
                print(error)
            }
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
}
