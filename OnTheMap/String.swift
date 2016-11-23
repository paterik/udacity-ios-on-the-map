//
//  String.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 23.11.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import Foundation

extension String {
    
    func chopPrefix(_ count: Int = 1) -> String {
        return self.substring(from: self.characters.index(self.startIndex, offsetBy: count))
    }
    
    func chopSuffix(_ count: Int = 1) -> String {
        return self.substring(to: self.characters.index(self.startIndex, offsetBy: count))
    }
}
