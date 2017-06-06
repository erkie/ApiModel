import Alamofire

open class ApiRequest {
    open var config: ApiConfig
    open var method: Alamofire.HTTPMethod
    open var path: String
    open var parameters: [String:Any] = [:]
    open var headers: [String:String] = [:]
    open var userInfo: [String:Any] = [:]
    
    open var encoding: ParameterEncoding {
        return config.encoding
    }
    
    public init(config: ApiConfig, method: Alamofire.HTTPMethod, path: String) {
        self.config = config
        self.method = method
        self.path = path
    }
    
    open var url: String {
        if NSURL(string: path)?.scheme?.isEmpty ?? true {
            return config.host + path
        } else {
            return path
        }
    }
}
