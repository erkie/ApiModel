public class ApiConfiguration {
    public var host: String = ""
    public var requestLogging: Bool = false

    public required init() {
        
    }
    
    public convenience init(host: String) {
        self.init()
        self.host = host
    }
}
