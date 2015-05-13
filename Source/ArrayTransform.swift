import Foundation
import RealmSwift

public class ArrayTransform<T: Object where T:ApiTransformable>: Transform {
    public init() {}

    public func perform(value: AnyObject?) -> AnyObject {
        if let values = value as? [[String:AnyObject]] {
            var models: [AnyObject] = []
            for nestedData in values {
                var model = T(completelyBogusInitializerDoesNothing: true)
                updateRealmObjectFromDictionaryWithMapping(model, nestedData, T.fromJSONMapping())

                models.append(model)
            }
            return models
        } else {
            return []
        }
    }
}
