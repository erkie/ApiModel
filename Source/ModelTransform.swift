import Foundation
import RealmSwift

open class ModelTransform<T: Object>: Transform where T:ApiModel {
    public init() {}

    open func perform(_ value: Any?, realm: Realm?) -> Any? {
        if let value = value as? [String:Any] {
            let model: T
            
            if let pk = T.primaryKey(),
                let pkValue = convertToApiId(value[pk]),
                let realm = realm,
                let alreadyPersistedModel = realm.object(ofType: T.self, forPrimaryKey: pkValue as Any)
            {
                model = alreadyPersistedModel
            } else {
                model = T()
            }
            
            let mapping = T.fromJSONMapping()
            updateRealmObjectFromDictionaryWithMapping(model, data: value, mapping: mapping, originRealm: realm)
            
            // If a realm is passed in we need to make sure to add the model in an update: true transaction, otherwise issues might happen down the road if the same object is present multiple times in a large nested response
            if let realm = realm {
                realm.add(model, update: .all)
            }
            
            return model
        } else {
            return T()
        }
    }
}
