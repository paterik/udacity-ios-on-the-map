//
//  FBClient.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 29.11.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//  
//  not realy a client may be more like a login client logic helper class
//

import Foundation
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

class FBClient: NSObject {
    
    //
    // MARK: Constants
    //
    static let sharedInstance = FBClient()
    
    func getUserSessionToken(completionHandlerForToken: @escaping (_ success: Bool, _ udcSession: FBSession?, _ message: String?) -> Void) {
        
    }
}
