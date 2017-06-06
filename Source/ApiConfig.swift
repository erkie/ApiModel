import Alamofire

open class ApiConfig {
    open var host: String = ""
    open var parser: ApiParser = JSONParser()
    open var encoding: ParameterEncoding = URLEncoding.default
    open var requestLogging: Bool = true
    open var rootNamespace = ""
    open var urlSessionConfig: URLSessionConfiguration?
    
    public required init() {
    }
    
    public convenience init(host: String, urlSessionConfig: URLSessionConfiguration) {
        self.init()
        self.host = host
        self.urlSessionConfig = urlSessionConfig
    }

    public convenience init(host: String) {
        self.init()
        self.host = host
    }
    
    public convenience init(apiConfig: ApiConfig) {
        self.init()
        self.host = apiConfig.host
        self.parser = apiConfig.parser
        self.encoding = apiConfig.encoding
        self.requestLogging = apiConfig.requestLogging
        self.rootNamespace = apiConfig.rootNamespace
        self.urlSessionConfig = apiConfig.urlSessionConfig
    }
    
    open func copy() -> ApiConfig {
        return ApiConfig(apiConfig: self)
    }
}
