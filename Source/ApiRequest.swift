import Alamofire

public class ApiRequest {
    public var path: String
    public var parameters: [String:AnyObject] = [:]
    public var method: Alamofire.Method

    public init(method: Alamofire.Method, path: String) {
        self.method = method
        self.path = path
    }

    public var url: String {
        get {
            return api().configuration.host + path
        }
    }
}
