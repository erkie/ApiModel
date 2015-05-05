//
//  ArrayTransform.swift
//  APIModel
//
//  Copyright (c) 2015 Rootof Creations HB. All rights reserved.
//

import Foundation
import Realm

public class ArrayTransform<T: RLMObject where T:ApiTransformable>: Transform {
    public init() {}
    
    public func perform(value: AnyObject?) -> AnyObject {
        if let values = value as? [[String:AnyObject]] {
            var models: [AnyObject] = []
            for nestedData in values {
                var model = T()
                updateRealmObjectFromDictionaryWithMapping(model, nestedData, T.fromJSONMapping())
                
                models.append(model)
            }
            return models
        } else {
            return []
        }
    }
}
