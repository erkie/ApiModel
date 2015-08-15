import Foundation

public class ApiResponse {
    public var request: ApiRequest
    public var responseBody: String?
    public var error: NSError?
    public var status: Int?
    public var parsedResponse: AnyObject?
    
    public var isStatusSuccessful: Bool {
        if let status = status {
            return status >= 200 && status <= 299
        } else {
            return false
        }
    }
    
    public init(request: ApiRequest) {
        self.request = request
    }
}
