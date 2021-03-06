//
//  GClientCache.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 31.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import Foundation

class GClientCache {

    //
    // MARK: Constants (Statics)
    //
    
    static let sharedInstance = GClientCache()
    
    //
    // MARK: Variables
    //
    
    var metaData = [GClientSession]()
    
    //
    // MARK: Methods (Public)
    //
    
    func clearCache() {
    
        metaData.removeAll()
    }
}
