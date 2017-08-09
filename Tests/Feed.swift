//
//  Post.swift
//  ApiModel
//
//  Created by Craig Heneveld on 1/14/16.
//
//

import Foundation
import RealmSwift
import ApiModel

// A test model for nested models
class Feed: Object, ApiModel {
    dynamic var id = ""
    dynamic var title = ""
    let posts = List<Post>()
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    class func apiNamespace() -> String {
        return "feed"
    }
    
    class func apiRoutes() -> ApiRoutes {
        return ApiRoutes()
    }
    
    class func fromJSONMapping() -> JSONMapping {
        return [
            "id": ApiIdTransform(),
            "title": StringTransform(),
            "posts": ArrayTransform<Post>()
        ]
    }
    
    // Define how this object is to be serialized back into a server response format
    func JSONDictionary() -> [String:Any] {
        return [
            "id": id as AnyObject,
            "title": title as AnyObject,
            "posts": posts.map { $0.JSONDictionary() }
        ]
    }
}
