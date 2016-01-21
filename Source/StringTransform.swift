import Foundation
import RealmSwift

public class StringTransform: Transform {
    public init() {}

    public func perform(value: AnyObject?, realm: Realm?) -> AnyObject? {
        if value is String {
            return value!
        } else if let intValue = value as? Int {
            return String(intValue)
        } else if let stringValue = value?.stringValue {
            return stringValue
        } else {
            return ""
        }
    }
}
