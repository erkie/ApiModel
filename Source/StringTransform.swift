import Foundation
import RealmSwift

open class StringTransform: Transform {
    public init() {}

    open func perform(_ value: Any?, realm: Realm?) -> Any? {
        if value is String {
            return value!
        } else if let intValue = value as? Int {
            return String(intValue)
        } else if let stringValue = (value as AnyObject?)?.stringValue {
            return stringValue
        } else {
            return ""
        }
    }
}
