//
//  Builder.swift
//  APIModel
//
//  Created by Erik Rothoff Andersson on 2016-05-04.
//
//

import Foundation
import SwiftyJSON

extension JSON {
    public init(object: [String:AnyObject?]) {
        let objectWithoutNil: [(String, AnyObject)] = object.map { (key, value) in
            if let value = value {
                return (key, value)
            } else {
                return (key, NSNull())
            }
        }
        
        var dict: [String:AnyObject] = [:]
        for (key, value) in objectWithoutNil {
            dict[key] = value
        }
        
    
        self.init(dict as NSDictionary)
    }
}

public class Builder {
    public init() {
    }
    
    public func build(data: JSON) -> JSON {
        return data
    }
    
    public func buildNil() -> JSON {
        return JSON(NSNull())
    }
}