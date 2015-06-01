import Foundation
import RealmSwift

func convertNSDictionaryToDictionary(nsDict: NSDictionary) -> Dictionary<String, AnyObject> {
    var dict: [String: AnyObject] = [:]

    for (key, value) in nsDict {
        dict[key.description!] = value as AnyObject
    }

    return dict
}

func JSONtoDictionary(dict: [String:JSON]) -> [String:[String]] {
    var newDict: [String:[String]] = [:]

    for (key, value) in dict {
        if let errors = value.arrayObject {
            var err: [String] = []
            for errorMessage in errors {
                if let e = errorMessage as? String {
                    err.append(e)
                }
            }
            newDict[key] = err
        }
    }

    return newDict
}

public func toArray<T: Object>(realmArray: List<T>) -> [T] {
    var retArray: [T] = []
    for obj in realmArray {
        retArray.append(obj)
    }
    return retArray
}