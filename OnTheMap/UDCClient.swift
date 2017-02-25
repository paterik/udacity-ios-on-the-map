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
    // MARK: Constants (Statics)
    //
    static let sharedInstance = UDCClient()

    //
    // MARK: Constants (Normal)
    //
    let debugMode: Bool = true
    let dateFormatter = DateFormatter()
    let session = URLSession.shared
    let apiURL: String = "https://www.udacity.com/api/session"
    let apiSkipCharCount: Int = 5

    //
    // MARK: Properties
    //
    var username: String?
    var password: String?
    var jsonBody: String = "{}"

}
