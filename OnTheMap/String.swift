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
    
    /*
     * get a emoji flag by given country iso-code, return "🏴" on invalid/unknown code
     */
    func getFlagByCountryISOCode() -> String {
        
        for localeISOCode in NSLocale.isoCountryCodes {
            
            if self == localeISOCode {
                return self.unicodeScalars.flatMap { String.init(UnicodeScalar(127397 + $0.value)!) }.joined()
            }
        }
        
        return "🏴"
    }
    
    func validateMediaURL() -> Bool {
        
        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try? NSDataDetector(types: types.rawValue)
        
        guard (detector != nil && self.characters.count > 0) else { return false }
        
        if detector!.numberOfMatches(
            in: self,
            options: NSRegularExpression.MatchingOptions(rawValue: 0),
            range: NSMakeRange(0, self.characters.count)) > 0 {
            
            return true
        }
        
        return false
    }
}
