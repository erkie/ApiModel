import Foundation
import Alamofire

public typealias RequestParameters = [String:AnyObject]

open class ApiCall {
    open var method: Alamofire.HTTPMethod
    open var path: String
    open var parameters: RequestParameters = [:]
    open var namespace: String = ""

    public required init(method: Alamofire.HTTPMethod, path: String) {
        self.method = method
        self.path = path
    }
    
    public convenience init(method: Alamofire.HTTPMethod, path: String, parameters: RequestParameters, namespace: String) {
        self.init(method: method, path: path)
        self.parameters = parameters
        self.namespace = namespace
    }
}
