import Foundation

public class BoolTransform: Transform {
    public init() {}

    public func perform(value: AnyObject?) -> AnyObject? {
        if let stringValue = value?.stringValue {
            switch stringValue.lowercaseString {
            case "true": return true
            case "1": return true
            case "false": return false
            case "0": return false
            default: return false
            }
        }

        if let integerValue = value?.integerValue {
            if integerValue == 0 {
                return false
            } else {
                return true
            }
        }

        if value == nil {
            return false
        }

        return true
    }
}
