import Foundation

public protocol Transform {
    func perform(value: AnyObject?) -> AnyObject?
}
