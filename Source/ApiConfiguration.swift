import Alamofire

public class ApiConfiguration {
    public var host: String = ""
    public var parser: ApiParser = JSONParser()
    public var encoding: ParameterEncoding = .URL
    public var requestLogging: Bool = true

    public required init() {

    }

    public convenience init(host: String) {
        self.init()
        self.host = host
    }
}
