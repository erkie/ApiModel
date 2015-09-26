import Alamofire

public class ApiConfig {
    public var host: String = ""
    public var parser: ApiParser = JSONParser()
    public var encoding: ParameterEncoding = .URL
    public var requestLogging: Bool = true
    public var rootNamespace = ""

    public required init() {
    }

    public convenience init(host: String) {
        self.init()
        self.host = host
    }
}
