import Foundation
import RealmSwift

open class IntTransform: Transform {
    public init() {}

    open func perform(_ value: Any?, realm: Realm?) -> Any? {
        if let asInt = (value as AnyObject).int64Value {
            return asInt
        } else {
            return 0
        }
    }
}
