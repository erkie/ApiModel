import Foundation
import RealmSwift
import SwiftyJSON

public func toArray<T: Object>(_ realmArray: List<T>) -> [T] {
    var retArray: [T] = []
    for obj in realmArray {
        retArray.append(obj)
    }
    return retArray
}

public func toArray<T: Object>(_ realmResult: Results<T>) -> [T] {
    var retArray: [T] = []
    for obj in realmResult {
        retArray.append(obj)
    }
    return retArray
}

// Traverse a nested dictionary using dot-notation path
public func fetchPathFromDictionary(_ namespace: String, dictionary: [String:Any]) -> Any? {
    var pieces = namespace.components(separatedBy: ".")
    
    var current: [String:Any] = dictionary
    
    while !pieces.isEmpty {
        let piece = pieces.remove(at: 0)
        if pieces.isEmpty {
            return current[piece]
        }
        
        if let nextDictionary = current[piece] as? [String:Any] {
            current = nextDictionary
        } else {
            return nil
        }
    }
    
    return nil
}
