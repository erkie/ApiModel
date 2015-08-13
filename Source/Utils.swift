import Foundation
import RealmSwift
import SwiftyJSON

public func toArray<T: Object>(realmArray: List<T>) -> [T] {
    var retArray: [T] = []
    for obj in realmArray {
        retArray.append(obj)
    }
    return retArray
}

public func toArray<T: Object>(realmResult: Results<T>) -> [T] {
    var retArray: [T] = []
    for obj in realmResult {
        retArray.append(obj)
    }
    return retArray
}

// Traverse a nested dictionary using dot-notation path
public func fetchPathFromDictionary(namespace: String, dictionary: [String:AnyObject]) -> AnyObject? {
    var pieces = namespace.componentsSeparatedByString(".")
    
    var current: [String:AnyObject] = dictionary
    
    while !pieces.isEmpty {
        let piece = pieces.removeAtIndex(0)
        if pieces.isEmpty {
            return current[piece]
        }
        
        if let nextDictionary = current[piece] as? [String:AnyObject] {
            current = nextDictionary
        } else {
            return nil
        }
    }
    
    return nil
}