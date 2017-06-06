import Foundation
import RealmSwift

extension Object {
    public class func localId() -> ApiId {
        return "APIMODELLOCAL-\(NSUUID().uuidString)"
    }
    
    public var isLocal: Bool {
        if let pk = type(of: self).primaryKey() {
            if let id = self[pk] as? NSString {
                return id.range(of: "APIMODELLOCAL-").location == 0
            }
        }
        
        return false
    }
    
    public var unlocalId: ApiId {
        if isLocal {
            return ""
        } else if let pk = type(of: self).primaryKey(),
            let id = convertToApiId(self[pk] as AnyObject)
        {
            return id
        } else {
            return ""
        }
    }

    public func isApiSaved() -> Bool {
        if let pk = type(of: self).primaryKey(),
            let idValue = convertToApiId(self[pk] as AnyObject)
        {
            return !idValue.isEmpty
        } else {
            return false
        }
    }

    public func modifyStoredObject(_ modifyingBlock: () -> ()) {
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

    public func removeEmpty(_ fieldsToRemoveIfEmpty: [String], data: [String:AnyObject]) -> [String:AnyObject] {
        var data = data
        for field in fieldsToRemoveIfEmpty {
            if data[field] == nil {
                data.removeValue(forKey: field)
            } else if let value = data[field] as? String, value.isEmpty {
                data.removeValue(forKey: field)
            }
        }
        return data
    }

    public func apiRouteWithReplacements(_ url: String) -> String {
        var pieces = url.components(separatedBy: ":")

        var pathComponents: [String] = []
        while pieces.count > 0 {
            pathComponents.append(pieces.remove(at: 0))
            if pieces.count == 0 {
                break
            }

            let methodName = pieces.remove(at: 0)
            if let value = self[methodName] {
                pathComponents.append((value as AnyObject).description)
            }
        }

        return pathComponents.joined(separator: "")
    }

    public func apiUrlForRoute(_ resource: String) -> String {
        return "\(apiManager().config.host)\(apiRouteWithReplacements(resource))"
    }
    
    public func apiUrlForRoute(_ resource: ApiRoutesAction) -> String {
        let apiRoutes = type(of: (type(of: self) as! ApiModel)).apiRoutes()
        return apiUrlForRoute(apiRoutes.getAction(resource))
    }
}
