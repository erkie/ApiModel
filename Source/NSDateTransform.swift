//
//  NSDateTransform.swift
//  APIModel
//
//  Copyright (c) 2015 Rootof Creations HB. All rights reserved.
//

import Foundation

public class NSDateTransform: Transform {
    public init() {}
    
    public func perform(value: AnyObject) -> AnyObject {
        if let dateValue = value as? NSDate {
            return dateValue
        }
        
        // Rails dates with time and zone
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        if let date = dateFormatter.dateFromString("\(value)") {
            return toLocalTimezone(date)
        }
        
        // Standard short dates
        let simpleDateFormatter = NSDateFormatter()
        simpleDateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = simpleDateFormatter.dateFromString("\(value)") {
            return toLocalTimezone(date)
        }

        return NSDate()
    }
    
    func toLocalTimezone(date: NSDate) -> NSDate {
        let seconds = NSTimeInterval(NSTimeZone.localTimeZone().secondsFromGMTForDate(date))
        return NSDate(timeInterval: seconds, sinceDate: date)
    }
}
