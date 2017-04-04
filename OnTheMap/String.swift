//
//  String.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 23.11.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import Foundation

extension String {

    /*
     * add capitalization for given strings
     */
    func capitalizingFirstLetter() -> String {
        
        if self.isEmpty { return self }
        
        let first = String(self.characters.prefix(1)).capitalized
        let other = String(self.characters.dropFirst())
        
        return first + other
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
    
    /*
     * validate string for usable url's using the simple way
     */
    func validateURL() -> Bool {
        
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
