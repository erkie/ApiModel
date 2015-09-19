import Foundation
import RealmSwift

public class FloatTransform: Transform {
    public init() {}

    public func perform(value: AnyObject?) -> AnyObject? {
        if let asFloat = value?.floatValue {
            return asFloat
        } else {
            return 0
        }
    }
}
