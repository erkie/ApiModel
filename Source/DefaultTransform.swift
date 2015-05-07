import Foundation

public class DefaultTransform: Transform {
    var defaultValue: AnyObject

    public init(defaultValue: AnyObject) {
        self.defaultValue = defaultValue
    }

    public func perform(value: AnyObject?) -> AnyObject {
        if value == nil {
            return defaultValue
        } else {
            return value!
        }
    }
}
