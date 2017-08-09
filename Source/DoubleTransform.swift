import Foundation
import RealmSwift

open class DoubleTransform: Transform {
	public init() {}

	open func perform(_ value: Any?, realm: Realm?) -> Any? {
		if let doubleValue = value as? Double {
			return doubleValue
		} else if let stringValue = value as? String {
			return (stringValue as NSString).doubleValue
		} else {
			return 0
		}
	}
}
