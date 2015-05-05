//
//  IntTransform.swift
//  APIModel
//
//  Copyright (c) 2015 Rootof Creations HB. All rights reserved.
//

import Foundation

public class IntTransform: Transform {
    public init() {}
    
    public func perform(value: AnyObject?) -> AnyObject {
        if let asInt = value?.integerValue {
            return asInt
        } else {
            return 0
        }
    }
}
