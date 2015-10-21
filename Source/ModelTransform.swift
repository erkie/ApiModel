import Foundation
import RealmSwift

public class ModelTransform<T: Object where T:ApiModel>: Transform {
    public init() {}

    public func perform(value: AnyObject?) -> AnyObject? {
        if let value = value as? [String:AnyObject] {
            let model = T()
            let mapping = T.fromJSONMapping()
            updateRealmObjectFromDictionaryWithMapping(model, data: value, mapping: mapping)
            return model
        } else {
            return T()
        }
    }
}
