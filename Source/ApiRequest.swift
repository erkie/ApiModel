import Alamofire

public class ApiRequest {
    public var config: ApiConfig
    public var method: Alamofire.Method
    public var path: String
    public var parameters: [String:AnyObject] = [:]
    public var headers: [String:String] = [:]
    public var userInfo: [String:AnyObject] = [:]
    
    public var encoding: ParameterEncoding {
        return config.encoding
    }
    
    public init(config: ApiConfig, method: Alamofire.Method, path: String) {
        self.config = config
        self.method = method
        self.path = path
    }
    
    public var url: String {
        if NSURL(string: path)?.scheme.isEmpty ?? true {
            return config.host + path
        } else {
            return path
        }
    }
}
