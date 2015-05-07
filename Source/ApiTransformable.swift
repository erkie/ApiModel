import Foundation

public typealias JSONMapping = [String:Transform]

public protocol ApiTransformable {
    static func apiNamespace() -> String
    static func apiResource() -> ApiResource
    static func fromJSONMapping() -> JSONMapping
    func JSONDictionary() -> [String:AnyObject]
}
