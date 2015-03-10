//
//  ApiId.swift
//  APIModel
//
//  Copyright (c) 2015 Rootof Creations HB. All rights reserved.
//

public typealias ApiId = String

public class ApiIdTransform: Transform {
    public init() {}
    
    public func perform(value: AnyObject) -> AnyObject {
        if let stringValue = value as? String {
            return stringValue
        } else {
            return value.stringValue
        }
    }
}