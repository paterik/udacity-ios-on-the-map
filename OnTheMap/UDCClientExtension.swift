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
    
    func getSession(completionHandlerForToken: @escaping (_ success: Bool, _ sessionToken: String?, _ errorString: String?) -> Void) {
        
        let jsonAuthBody = renderJSONAuthBody()
        
        _ = taskForPOSTMethod(jsonBody: jsonAuthBody!) { (results, error) in
            
            if let error = error {
                
                completionHandlerForToken(false, nil, "Login Failed (SessionToken not available), Error: \(error)")
                
            } else {
                
                completionHandlerForToken(true, nil, "Login successfully done! (SessionToken available).")
    
            }
        }
    }
}
