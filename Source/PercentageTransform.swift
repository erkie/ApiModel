import Foundation
import RealmSwift

open class PercentageTransform: Transform {
    public init() {}

    open func perform(_ value: Any?, realm: Realm?) -> Any? {
        if let intValue = value as? Int {
            return Float(intValue) / Float(100.0)
        }
        if let stringValue = value as? String {
            return (stringValue as NSString).floatValue / Float(100.0)
        }
        return nil
    }
}
