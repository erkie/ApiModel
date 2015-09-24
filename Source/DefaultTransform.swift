import Foundation

public class DefaultTransform: Transform {
    var defaultValue: AnyObject

    public init(defaultValue: AnyObject) {
        self.defaultValue = defaultValue
    }

    public func perform(value: AnyObject?) -> AnyObject? {
        if let value = value {
            return value
        } else {
            return defaultValue
        }
    }
}
