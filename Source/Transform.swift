import Foundation
import RealmSwift

public protocol Transform {
    func perform(_ value: Any?, realm: Realm?) -> Any?
}
