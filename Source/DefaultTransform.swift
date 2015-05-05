//
//  DefaultTransform.swift
//  APIModel
//
//  Created by Erik Rothoff Andersson on 03/05/15.
//
//

import Foundation

public class DefaultTransform: Transform {
    var defaultValue: AnyObject
    
    public init(defaultValue: AnyObject) {
        self.defaultValue = defaultValue
    }
    
    public func perform(value: AnyObject?) -> AnyObject {
        if value == nil {
            return defaultValue
        } else {
            return value!
        }
    }
}