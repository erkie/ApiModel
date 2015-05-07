import Foundation

public class ApiResponse {
    public var request: ApiRequest
    public var json: JSON?
    public var error: NSError?
    public var status: Int?

    public init(request: ApiRequest) {
        self.request = request
    }
}
