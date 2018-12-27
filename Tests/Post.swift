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

class Post: Object, ApiModel {
    // Standard Realm boilerplate
    @objc dynamic var id = ""
    @objc dynamic var title = ""
    @objc dynamic var contents = ""
    @objc dynamic var createdAt: Date? = Date()
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    // Define the standard namespace this class usually resides in JSON responses
    // MUST BE singular ie `post` not `posts`
    class func apiNamespace() -> String {
        return "post"
    }
    
    // Define where and how to get these. Routes are assumed to use Rails style REST (index, show, update, destroy)
    class func apiRoutes() -> ApiRoutes {
        return ApiRoutes(
            index: "/posts.json",
            show: "/post/:id:.json"
        )
    }
    
    // Define how it is converted from JSON responses into Realm objects. A host of transforms are available
    // See section "Transforms" in README. They are super easy to create as well!
    class func fromJSONMapping() -> JSONMapping {
        return [
            "id": ApiIdTransform(),
            "title": StringTransform(),
            "contents": StringTransform(),
            "createdAt": DateTransform()
        ]
    }
    
    // Define how this object is to be serialized back into a server response format
    func JSONDictionary() -> [String:Any] {
        return [
            "id": id as AnyObject,
            "title": title as AnyObject,
            "contents": contents as AnyObject,
            "created_at": createdAt as AnyObject
        ]
    }
}
