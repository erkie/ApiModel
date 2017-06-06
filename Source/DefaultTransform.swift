import Foundation
import RealmSwift

open class DefaultTransform: Transform {
    var defaultValue: Any

    public init(defaultValue: Any) {
        self.defaultValue = defaultValue
    }

    open func perform(_ value: Any?, realm: Realm?) -> Any? {
        if let value = value {
            return value
        } else {
            return defaultValue
        }
    }
}
