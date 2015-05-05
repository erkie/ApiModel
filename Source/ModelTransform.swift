//
//  ModelTransform.swift
//  APIModel
//
//  Copyright (c) 2015 Rootof Creations HB. All rights reserved.
//

import Foundation
import Realm

public class ModelTransform<T: RLMObject where T:ApiTransformable>: Transform {
    public init() {}
    
    public func perform(value: AnyObject?) -> AnyObject {
        if let value = value as? [String:AnyObject] {
            var model = T()
            updateRealmObjectFromDictionaryWithMapping(model, value, T.fromJSONMapping())
            return model
        } else {
            return T()
        }
    }
}