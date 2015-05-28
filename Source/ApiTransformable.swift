import Foundation

public typealias JSONMapping = [String:Transform]

public protocol ApiTransformable {
    static func apiNamespace() -> String
    static func apiRoutes() -> ApiRoutes
    static func fromJSONMapping() -> JSONMapping
    func JSONDictionary() -> [String:AnyObject]
}
