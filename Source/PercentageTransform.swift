import Foundation
import RealmSwift

public class PercentageTransform: Transform {
    public init() {}

    public func perform(value: AnyObject?, realm: Realm?) -> AnyObject? {
        if let intValue = value as? Int {
            return Float(intValue) / 100.0
        }
        if let stringValue = value as? String {
            return (stringValue as NSString).floatValue / 100.0
        }
        return nil
    }
}
