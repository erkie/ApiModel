import Foundation

public typealias JSONMapping = [String:Transform]

public protocol ApiModel {
    static func apiNamespace() -> String
    static func apiRoutes() -> ApiRoutes
    static func fromJSONMapping() -> JSONMapping
    func JSONDictionary() -> [String:AnyObject]
}
