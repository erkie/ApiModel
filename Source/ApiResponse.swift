import Foundation

public class ApiResponse {
    public var request: ApiRequest
    public var responseBody: String?
    public var error: NSError?
    public var status: Int?
    public var parsedResponse: AnyObject?

    public init(request: ApiRequest) {
        self.request = request
    }
}
