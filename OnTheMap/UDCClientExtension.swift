//
//  UDCClientExtension.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 22.11.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import Foundation

extension UDCClient {


    private func getJSONAuthBody() -> String! {
        
        return ("{\"udacity\": {\"username\": \"\(username!)\", \"password\": \"\(password!)\"}}")
    }
    
    func getUserSessionToken(completionHandlerForToken: @escaping (_ success: Bool, _ udcSession: UDCSession?, _ message: String?) -> Void) {
        
        guard (username != nil) else {
            completionHandlerForToken(false, nil, "Up's, there was an error with your request udacity request, no username provided!")
            return
        }
        
        guard (password != nil) else {
            completionHandlerForToken(false, nil, "Up's, there was an error with your request udacity request, no password provided!")
            return
        }
        
        _ = taskForPOSTMethod(jsonBody: getJSONAuthBody()!) { (results, _error) in
            
            if let error = _error {
                completionHandlerForToken(false, nil, "Login Failed (SessionToken not available), Error: \(error)")
                return
            }
            
            // try to typeHint udacity auth json object response
            guard let resultBlock = results as? [String: AnyObject],
                let account = resultBlock["account"] as? [String: AnyObject],
                let session = resultBlock["session"] as? [String: AnyObject],
                let _accountKey = account["key"] as? String,
                let _accountRegistered = account["registered"] as? Bool,
                let _sessionId = session["id"] as? String,
                let _sessionExpirationDateString = session["expiration"] as? String
            
            else {
                
                completionHandlerForToken(false, nil, "Up's, unable to parse token-result! API structure changed gracefully!")
                return
            }
            
            // transform udacity auth json variable stack into our session object, setup dateFormatter for expiration date
            self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let udcSession = UDCSession(
                accountKey: _accountKey,
                accountRegistered: _accountRegistered,
                sessionId: _sessionId,
                sessionExpirationDate: self.dateFormatter.date(from: _sessionExpirationDateString),
                created: Date()
            )
            
            completionHandlerForToken(true, udcSession, "Login successfully done! (SessionToken available).")
        }
    }
}
