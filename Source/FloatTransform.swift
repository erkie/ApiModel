import Foundation
import RealmSwift

open class FloatTransform: Transform {
    public init() {}

    open func perform(_ value: Any?, realm: Realm?) -> Any? {
        if let asFloat = (value as AnyObject?)?.floatValue {
            return asFloat
        } else {
            return 0
        }
    }
}
