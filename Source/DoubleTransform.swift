import Foundation
import RealmSwift

public class DoubleTransform: Transform {
	public init() {}

	public func perform(value: AnyObject?, realm: Realm?) -> AnyObject? {
		if let doubleValue = value as? Double {
			return doubleValue
		} else if let stringValue = value as? String {
			return (stringValue as NSString).doubleValue
		} else {
			return 0
		}
	}
}
