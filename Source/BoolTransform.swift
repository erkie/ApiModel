import Foundation
import RealmSwift

open class BoolTransform: Transform {
    public init() {}

    open func perform(_ value: Any?, realm: Realm?) -> Any? {
        if let stringValue = (value as AnyObject?)?.stringValue {
            switch stringValue.lowercased() {
            case "true": return true
            case "1": return true
            case "false": return false
            case "0": return false
            default: return false
            }
        }

        if let integerValue = (value as AnyObject?)?.int64Value {
            if integerValue == 0 {
                return false as AnyObject
            } else {
                return true as AnyObject
            }
        }

        if value == nil {
            return false as AnyObject
        }

        return true as AnyObject
    }
}
