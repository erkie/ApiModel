import Foundation
import RealmSwift

public class ModelTransform<T: Object where T:ApiTransformable>: Transform {
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
