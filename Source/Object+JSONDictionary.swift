import Foundation
import RealmSwift

func camelizedString(_ string: String) -> String {
    var items: [String] = string.components(separatedBy: "_")
    var camelCase = items.remove(at: 0)
    for item: String in items {
        camelCase += item.capitalized
    }
    return camelCase
}

func updateRealmObjectFromDictionaryWithMapping(_ realmObject: Object, data: [String:Any], mapping: JSONMapping, originRealm: Realm?) {
    for (var key, value) in data {
        key = camelizedString(key)
        
        if let transform = mapping[key] {
            var optionalValue: AnyObject? = value as AnyObject?
            
            if (value as AnyObject).isKind(of: NSNull.self) {
                optionalValue = nil
            }
            
            let transformedValue = transform.perform(optionalValue, realm: originRealm)
            
            if let primaryKey = type(of: realmObject).primaryKey(),
                let modelsPrimaryKey = convertToApiId(realmObject[primaryKey] as AnyObject?),
                let responsePrimaryKey = convertToApiId(transformedValue), key == primaryKey && !modelsPrimaryKey.isEmpty
            {
                if modelsPrimaryKey == responsePrimaryKey {
                    continue
                } else {
                    print("APIMODEL WARNING: Api responded with different ID than stored. Changing this crashes Realm. Skipping (Tried to change \(modelsPrimaryKey) to \(responsePrimaryKey))")
                    continue
                }
            }
            
            realmObject[key] = transformedValue
        }
    }
}

extension Object {
    public func updateFromForm(_ data: NSDictionary) {
        let mapping = type(of: (self as! ApiModel)).fromJSONMapping()
        updateFromDictionaryWithMapping(data as! [String:AnyObject], mapping: mapping)
    }
    
    // We need to pass in JSONMapping manually because of problems in Swift
    // It's impossible to cast Objects to "Object that conforms to ApiModel" currently...
    public func updateFromForm(_ data: NSDictionary, mapping: JSONMapping) {
        updateFromDictionaryWithMapping(data as! [String:AnyObject], mapping: mapping)
    }
    
    public func updateFromDictionary(_ data: [String:Any]) {
        let mapping = type(of: (self as! ApiModel)).fromJSONMapping()
        updateRealmObjectFromDictionaryWithMapping(self, data: data, mapping: mapping, originRealm: realm)
    }
    
    public func updateFromDictionaryWithMapping(_ data: [String:AnyObject], mapping: JSONMapping) {
        updateRealmObjectFromDictionaryWithMapping(self, data: data, mapping: mapping, originRealm: realm)
    }
}
