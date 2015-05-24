import Foundation
import RealmSwift

public func toArray<T: Object>(realmArray: List<T>) -> [T] {
    var retArray: [T] = []
    for obj in realmArray {
        retArray.append(obj)
    }
    return retArray
}