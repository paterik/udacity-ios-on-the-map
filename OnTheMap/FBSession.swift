//
//  FBSession.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 28.11.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import Foundation

struct FBSession {
    
    let tokenString: String!
    
    let email: String!
    let userID: String!
    let userImgUrl: String!
    
    let appID: String!
    let permissions: Set<AnyHashable>?
    
    let expirationDate: Date!
    let refreshDate: Date!
    
    let created: Date!
}
