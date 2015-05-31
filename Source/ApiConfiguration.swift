public class ApiConfiguration {
    public var host: String = ""
    
    public required init() {
        
    }
    
    public convenience init(host: String) {
        self.init()
        self.host = host
    }
}
