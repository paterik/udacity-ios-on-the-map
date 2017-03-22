//
//  Double.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 22.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import Foundation

extension Double {
    
    func roundTo(_ places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        
        return (self * divisor).rounded() / divisor
    }
}
