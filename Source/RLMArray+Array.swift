import Foundation
import RealmSwift

public class ToArray<T: Object> {
    var realmArray: List<T>
    public init(realmArray: List<T>) {
        self.realmArray = realmArray
    }
    
    public func get() -> [T] {
        var retArray: [T] = []
        for obj in realmArray {
            retArray.append(obj)
        }
        return retArray
    }
}