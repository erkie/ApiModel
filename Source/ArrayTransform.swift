import Foundation
import RealmSwift

open class ArrayTransform<T: Object>: Transform where T:ApiModel {
    let nestedModelTransform = ModelTransform<T>()
    
    public init() {}

    open func perform(_ value: Any?, realm: Realm?) -> Any? {
        var models: [T] = []
        
        if let values = value as? [Any] {
            for value in values {
                if let nestedData = value as? [String:Any],
                    let model = nestedModelTransform.perform(nestedData as AnyObject, realm: realm) as? T
                {
                    models.append(model)
                }
            }
        }
            
        return models
    }
}
