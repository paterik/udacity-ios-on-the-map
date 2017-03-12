//
//  Int.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 11.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit


// Overloading + and - so that we can add and subtract DateComponents
// ------------------------------------------------------------------

func +(_ lhs: DateComponents, _ rhs: DateComponents) -> DateComponents {
    return combineComponents(lhs, rhs)
}

func -(_ lhs: DateComponents, _ rhs: DateComponents) -> DateComponents {
    return combineComponents(lhs, rhs, multiplier: -1)
}

func combineComponents(_ lhs: DateComponents,
                       _ rhs: DateComponents,
                       multiplier: Int = 1)
    -> DateComponents {
        var result = DateComponents()
        result.second     = (lhs.second     ?? 0) + (rhs.second     ?? 0) * multiplier
        result.minute     = (lhs.minute     ?? 0) + (rhs.minute     ?? 0) * multiplier
        result.hour       = (lhs.hour       ?? 0) + (rhs.hour       ?? 0) * multiplier
        result.day        = (lhs.day        ?? 0) + (rhs.day        ?? 0) * multiplier
        result.weekOfYear = (lhs.weekOfYear ?? 0) + (rhs.weekOfYear ?? 0) * multiplier
        result.month      = (lhs.month      ?? 0) + (rhs.month      ?? 0) * multiplier
        result.year       = (lhs.year       ?? 0) + (rhs.year       ?? 0) * multiplier
        return result
}

// Overloading - so that we can negate DateComponents
// --------------------------------------------------

// We'll need to overload unary - so we can negate components
prefix func -(components: DateComponents) -> DateComponents {
    var result = DateComponents()
    if components.second     != nil { result.second     = -components.second! }
    if components.minute     != nil { result.minute     = -components.minute! }
    if components.hour       != nil { result.hour       = -components.hour! }
    if components.day        != nil { result.day        = -components.day! }
    if components.weekOfYear != nil { result.weekOfYear = -components.weekOfYear! }
    if components.month      != nil { result.month      = -components.month! }
    if components.year       != nil { result.year       = -components.year! }
    return result
}

// Overloading + and - so that we can add Dates and DateComponents
// and subtract DateComponents from Dates

// Date + DateComponents
func +(_ lhs: Date, _ rhs: DateComponents) -> Date
{
    return Calendar.current.date(byAdding: rhs, to: lhs)!
}

// DateComponents + Dates
func +(_ lhs: DateComponents, _ rhs: Date) -> Date
{
    return rhs + lhs
}

// Date - DateComponents
func -(_ lhs: Date, _ rhs: DateComponents) -> Date
{
    return lhs + (-rhs)
}

// Extending Date so that creating dates is simpler
// ------------------------------------------------

extension Date {
    
    init(year: Int,
         month: Int,
         day: Int,
         hour: Int = 0,
         minute: Int = 0,
         second: Int = 0,
         timeZone: TimeZone = TimeZone(abbreviation: "UTC")!) {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        components.timeZone = timeZone
        self = Calendar.current.date(from: components)!
    }
    
    init(dateString: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss zz"
        self = formatter.date(from: dateString)!
    }
    
}


// The Stevenote where the original iPhone was announced took place
// on January 9, 2007 at 10:00 a.m. PST
let iPhoneStevenoteDate = Date(year: 2007,
                               month: 1,
                               day: 9,
                               hour: 10,
                               minute: 0,
                               second: 0,
                               timeZone: TimeZone(abbreviation: "PST")!)

// The original iPhone went on sale on June 27, 2007
let iPhoneReleaseDate = Date(year: 2007, month: 6, day: 27) // June 27, 2007, 00:00:00 UTC

// The Stevenote where the original iPhone was announced took place
// on January 27, 2010 at 10:00 a.m. PST
let iPadStevenoteDate = Date(dateString: "2010-01-27 10:00:00 PST")


// Overloading - so that we can use it to find the difference between two Dates

func -(_ lhs: Date, _ rhs: Date) -> DateComponents
{
    return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],
                                           from: rhs,
                                           to: lhs)
}


// Extending Int to add some syntactic magic to date components
// ------------------------------------------------------------

extension Int {
    
    var second: DateComponents {
        var components = DateComponents()
        components.second = self;
        return components
    }
    
    var seconds: DateComponents {
        return self.second
    }
    
    var minute: DateComponents {
        var components = DateComponents()
        components.minute = self;
        return components
    }
    
    var minutes: DateComponents {
        return self.minute
    }
    
    var hour: DateComponents {
        var components = DateComponents()
        components.hour = self;
        return components
    }
    
    var hours: DateComponents {
        return self.hour
    }
    
    var day: DateComponents {
        var components = DateComponents()
        components.day = self;
        return components
    }
    
    var days: DateComponents {
        return self.day
    }
    
    var week: DateComponents {
        var components = DateComponents()
        components.weekOfYear = self;
        return components
    }
    
    var weeks: DateComponents {
        return self.week
    }
    
    var month: DateComponents {
        var components = DateComponents()
        components.month = self;
        return components
    }
    
    var months: DateComponents {
        return self.month
    }
    
    var year: DateComponents {
        var components = DateComponents()
        components.year = self;
        return components
    }
    
    var years: DateComponents {
        return self.year
    }
    
}

// Extending DateComponents to add even more syntactic magic: fromNow and ago
// --------------------------------------------------------------------------

extension DateComponents {
    
    var fromNow: Date {
        return Calendar.current.date(byAdding: self,
                                     to: Date())!
    }
    
    var ago: Date {
        return Calendar.current.date(byAdding: -self,
                                     to: Date())!
    }
    
}
