//
//  RLMObject+extensions.swift
//  APIModel
//
//  Created by Erik Rothoff Andersson on 04/12/14.
//  Copyright (c) 2015 Rootof Creations HB. All rights reserved.
//

import Foundation
import Realm

func camelizedString(string: String) -> String {
    var items: [String] = string.componentsSeparatedByString("_")
    var camelCase = items.removeAtIndex(0)
    for item: String in items {
        camelCase += item.capitalizedString
    }
    return camelCase
}

func updateRealmObjectFromDictionaryWithMapping(realmObject: RLMObject, data: [String:AnyObject], mapping: JSONMapping) {
    for (var key, value) in data {
        key = camelizedString(key)
        
        if let mappingKey = mapping[key] {
            if value.isKindOfClass(NSNull) {
                continue
            }
            
            let transform = mapping[key]!
            realmObject[key] = transform.perform(value)
        }
    }
}

extension RLMObject {
    // We need to pass in JSONMapping manually because of problems in Swift
    // It's impossible to cast RLMObjects to "RLMObject that conforms to ApiTransformable" currently...
    public func updateFromForm(data: NSDictionary, mapping: JSONMapping) {
        updateFromDictionaryWithMapping(data as! [String:AnyObject], mapping: mapping)
    }
    
    public func updateFromDictionaryWithMapping(data: [String:AnyObject], mapping: JSONMapping) {
        updateRealmObjectFromDictionaryWithMapping(self, data, mapping)
    }
}
