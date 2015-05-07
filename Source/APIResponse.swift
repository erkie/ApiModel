import Foundation

public class APIResponse {
    public var request: APIRequest
    public var json: JSON?
    public var error: NSError?
    public var status: Int?

    public init(request: APIRequest) {
        self.request = request
    }
}
