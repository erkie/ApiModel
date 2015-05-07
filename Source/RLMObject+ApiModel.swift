import Foundation
import Realm

extension RLMObject {
    public class func localId() -> ApiId {
        return "APIMODELLOCAL-\(NSUUID().UUIDString)"
    }

    public func isApiSaved() -> Bool {
        let pk = self.dynamicType.primaryKey()
        
        if pk.isEmpty {
            return false
        }

        if let idValue = self[pk] as? String {
            return !idValue.isEmpty
        } else if let idValue = self[pk] as? Int {
            return idValue != 0
        } else {
            return false
        }
    }

    public var isLocal: Bool {
        get {
            if let id = self[self.dynamicType.primaryKey()] as? NSString {
                return id.rangeOfString("APIMODELLOCAL-").location == 0
            }

            return false
        }
    }

    public var unlocalId: ApiId {
        get {
            if isLocal {
                return ""
            } else if let id = self[self.dynamicType.primaryKey()] as? ApiId {
                return id
            } else {
                return ""
            }
        }
    }

    public func modifyStoredObject(modifyingBlock: () -> ()) {
        if realm == nil {
             modifyingBlock()
        } else {
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            modifyingBlock()
            realm.commitWriteTransaction()
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

    public func apiResourceWithReplacements(url: String) -> String {
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

        return "".join(pathComponents)
    }

    public func apiUrlForResource(resource: String) -> String {
        return "\(api().configuration.host)\(apiResourceWithReplacements(resource))"
    }
    
    /*
    Not possible because calling methods on protocol types is not implmented yet.
    public func apiUrlForResource(resource: ApiResourceAction) -> String {
        let apiResource = (self.dynamicType as! ApiTransformable).dynamicType.apiResource()
        return apiUrlForResource(apiResource.getAction(resource))
    }*/
}
