import Foundation
import RealmSwift

public class IntTransform: Transform {
    public init() {}

    public func perform(value: AnyObject?, realm: Realm?) -> AnyObject? {
        if let asInt = value?.integerValue {
            return asInt
        } else {
            return 0
        }
    }
}
