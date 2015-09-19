import Foundation

public class IntTransform: Transform {
    public init() {}

    public func perform(value: AnyObject?) -> AnyObject? {
        if let asInt = value?.integerValue {
            return asInt
        } else {
            return 0
        }
    }
}
