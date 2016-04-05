//
//  Builder.swift
//  APIModel
//
//  Created by Erik Rothoff Andersson on 2016-05-04.
//
//

import Foundation

public class Builder {
    public init() {
    }
    
    public func build(data: [String:AnyObject?]) -> AnyObject? {
        return buildObject(data)
    }
    
    public func build(data: [AnyObject?]) -> AnyObject? {
        return nil
    }
    
    public func buildObject(data: [String:AnyObject?]) -> AnyObject? {
        // TODO: Move ApiFormResponse stuff here
        return nil
    }
}