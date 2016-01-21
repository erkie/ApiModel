import Foundation
import RealmSwift

public class DefaultTransform: Transform {
    var defaultValue: AnyObject

    public init(defaultValue: AnyObject) {
        self.defaultValue = defaultValue
    }

    public func perform(value: AnyObject?, realm: Realm?) -> AnyObject? {
        if let value = value {
            return value
        } else {
            return defaultValue
        }
    }
}
