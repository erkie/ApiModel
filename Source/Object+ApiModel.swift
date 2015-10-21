import Foundation
import RealmSwift

extension Object {
    public class func localId() -> ApiId {
        return "APIMODELLOCAL-\(NSUUID().UUIDString)"
    }
    
    public var isLocal: Bool {
        if let pk = self.dynamicType.primaryKey() {
            if let id = self[pk] as? NSString {
                return id.rangeOfString("APIMODELLOCAL-").location == 0
            }
        }
        
        return false
    }
    
    public var unlocalId: ApiId {
        if isLocal {
            return ""
        } else if let
            pk = self.dynamicType.primaryKey(),
            id = self[pk] as? ApiId {
                return id
        } else {
            return ""
        }
    }

    public func isApiSaved() -> Bool {
        if let pk = self.dynamicType.primaryKey() {
            if let idValue = self[pk] as? String {
                return !idValue.isEmpty
            } else if let idValue = self[pk] as? Int {
                return idValue != 0
            } else {
                return false
            }
        } else {
            return false
        }
    }

    public func modifyStoredObject(modifyingBlock: () -> ()) {
        if let realm = realm {
            // This is up for discussion, ideally the user should handle this, but in the short term would require too much error logic
            try! realm.write(modifyingBlock)
        } else {
            modifyingBlock()
        }
    }

    public func saveStoredObject() {
        modifyStoredObject {}
    }

    public func removeEmpty(fieldsToRemoveIfEmpty: [String], var data: [String:AnyObject]) -> [String:AnyObject] {
        for field in fieldsToRemoveIfEmpty {
            if data[field] == nil {
                data.removeValueForKey(field)
            } else if let value = data[field] as? String where value.isEmpty {
                data.removeValueForKey(field)
            }
        }
        return data
    }

    public func apiRouteWithReplacements(url: String) -> String {
        var pieces = url.componentsSeparatedByString(":")

        var pathComponents: [String] = []
        while pieces.count > 0 {
            pathComponents.append(pieces.removeAtIndex(0))
            if pieces.count == 0 {
                break
            }

            let methodName = pieces.removeAtIndex(0)
            if let value: AnyObject = self[methodName] {
                pathComponents.append(value.description)
            }
        }

        return pathComponents.joinWithSeparator("")
    }

    public func apiUrlForRoute(resource: String) -> String {
        return "\(apiManager().config.host)\(apiRouteWithReplacements(resource))"
    }
    
    public func apiUrlForRoute(resource: ApiRoutesAction) -> String {
        let apiRoutes = (self.dynamicType as! ApiModel).dynamicType.apiRoutes()
        return apiUrlForRoute(apiRoutes.getAction(resource))
    }
}
