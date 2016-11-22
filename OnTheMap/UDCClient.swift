//
//  UDCClient.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 22.11.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import Foundation

class UDCClient: NSObject {
    
    static let sharedInstance = UDCClient()
    
    let debugMode: Bool = true
    let domainPrefix: String = "udacity.client"
    let apiURL: String = "https://www.udacity.com/api/session"
    
    var username: String?
    var password: String?

    //
    // MARK: properties
    //
    var session = URLSession.shared
    var jsonBody: String = "{}"

    //
    // MARK: Initializers
    //
    override init() {
        super.init()
        
        guard (username == nil) else {
            print("Up's, there was an error with your request udacity request, no username provided!")
            return
        }
        
        guard (password == nil) else {
            print("Up's, there was an error with your request udacity request, no password provided!")
            return
        }
    }
    
    func taskForPOSTMethod(
        jsonBody: String,
        completionHandlerForPOST: @escaping (_ result: Any?, _ error: NSError?) -> Void) -> URLSessionDataTask {
    
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: URL(string: apiURL)!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            func sendError(error: String) {
                
                completionHandlerForPOST(
                    nil,
                    NSError(domain: "\(self.domainPrefix)_taskForPOSTMethod",
                            code: 1,
                            userInfo: [NSLocalizedDescriptionKey : error]
                    )
                )
                
                if self.debugMode {
                    print(error)
                }
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError(error: "Up's, there was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                print ("\n [\((response as? HTTPURLResponse)?.statusCode )], data=[\(data)] \n")
                sendError(error: "Up's, your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError(error: "Up's, no data was returned by the request!")
                return
            }
            
            let range = Range(uncheckedBounds: (5, data.count - 5))
            let newData = data.subdata(in: range)
            if self.debugMode {
                print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(
                data: newData as NSData,
                completionHandlerForConvertData: completionHandlerForPOST
            )
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
        
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(
        data: NSData,
        completionHandlerForConvertData: (_ result: Any?, _ error: NSError?) -> Void) {
        
        var parsedResult: Any!
        
        do {
            
            parsedResult = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments)
            
        } catch {
            
            completionHandlerForConvertData(
                nil,
                NSError(domain: "\(self.domainPrefix)_convertDataWithCompletionHandler",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey : "Up's, could not parse the data as JSON: '\(data)'"]
                )
            )
            
            if self.debugMode {
                print(error)
            }
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
}
