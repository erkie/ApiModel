import Alamofire

public class ApiRequest {
    public var configuration: ApiConfiguration
    public var method: Alamofire.Method
    public var path: String
    public var parameters: [String:AnyObject] = [:]
    public var userInfo: [String:AnyObject] = [:]

    public init(configuration: ApiConfiguration, method: Alamofire.Method, path: String) {
        self.configuration = configuration
        self.method = method
        self.path = path
    }

    public var url: String {
        get {
            return configuration.host + path
        }
    }
}
