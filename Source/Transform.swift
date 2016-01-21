import Foundation
import RealmSwift

public protocol Transform {
    func perform(value: AnyObject?, realm: Realm?) -> AnyObject?
}
