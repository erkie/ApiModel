import Foundation
import RealmSwift

public class ModelTransform<T: Object where T:ApiModel>: Transform {
    public init() {}

    public func perform(value: AnyObject?, realm: Realm?) -> AnyObject? {
        if let value = value as? [String:AnyObject] {
            let model: T
            
            if let pk = T.primaryKey(),
                let pkValue = convertToApiId(value[pk]),
                let realm = realm,
                let alreadyPersistedModel = realm.objectForPrimaryKey(T.self, key: pkValue)
            {
                model = alreadyPersistedModel
            } else {
                model = T()
            }
            
            let mapping = T.fromJSONMapping()
            updateRealmObjectFromDictionaryWithMapping(model, data: value, mapping: mapping, originRealm: realm)
            
            // If a realm is passed in we need to make sure to add the model in an update: true transaction, otherwise issues might happen down the road if the same object is present multiple times in a large nested response
            if let realm = realm {
                realm.add(model, update: true)
            }
            
            return model
        } else {
            return T()
        }
    }
}
