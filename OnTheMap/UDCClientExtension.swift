//
//  UDCClientExtension.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 22.11.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import Foundation

extension UDCClient {

    
    func renderJSONAuthBody() -> String! {
        
        return ("{\"udacity\": {\"username\": \"\(username!)\", \"password\": \"\(password!)\"}}")
    }
    
    func getSession(completionHandlerForToken: @escaping (_ success: Bool, _ requestToken: String?, _ errorString: String?) -> Void) {
        
        let jsonAuthBody = renderJSONAuthBody()
        
        _ = taskForPOSTMethod(jsonBody: jsonAuthBody!) { (results, error) in
            
            if let error = error {
                
                if self.debugMode {
                    print(error)
                }
                
                completionHandlerForToken(false, nil, "Login Failed (Request Token).")
                
            } else {
                
                if self.debugMode {
                    print( "Login successfully done!" )
                }
            }
        }
    }
}
