//
//  PRSClient.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 27.12.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import Foundation

class PRSClient: NSObject {
    
    //
    // MARK: Constants (Statics)
    //
    static let sharedInstance = PRSClient()

    //
    // MARK: Constants (Normal)
    //
    let debugMode: Bool = true
    let session = URLSession.shared
    let apiURL: String = "https://parse.udacity.com/parse/classes/StudentLocation"
    let apiHeaderAuth = [
        "X-Parse-Application-Id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
        "X-Parse-REST-API-Key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    ]
    
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
            guard error == nil else {
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
        }
        
        /* Finaly start the corresponding request */
        task.resume()
        
        return task
    }

}
