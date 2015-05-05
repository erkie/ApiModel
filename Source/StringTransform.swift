//
//  StringTransform.swift
//  APIModel
//
//  Copyright (c) 2015 Rootof Creations HB. All rights reserved.
//

import Foundation

public class StringTransform: Transform {
    public init() {}
    
    public func perform(value: AnyObject?) -> AnyObject {
        if value is String {
            return value!
        } else if let stringValue = value?.stringValue {
            return stringValue
        } else {
            return ""
        }
    }
}
