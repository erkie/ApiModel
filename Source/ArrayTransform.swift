import Foundation
import RealmSwift

public class ArrayTransform<T: Object where T:ApiModel>: Transform {
    let nestedModelTransform = ModelTransform<T>()
    
    public init() {}

    public func perform(value: AnyObject?, realm: Realm?) -> AnyObject? {
        var models: [T] = []
        
        if let values = value as? [AnyObject] {
            for value in values {
                if let nestedData = value as? [String:AnyObject],
                    let model = nestedModelTransform.perform(nestedData, realm: realm) as? T
                {
                    models.append(model)
                }
            }
        }
            
        return models
    }
}
