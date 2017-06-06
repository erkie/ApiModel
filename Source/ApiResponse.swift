import Foundation

public enum ApiResponseError: Error {
    case none
    case parseError
    case badRequest(code: Int)
    case invalidRequest(code: Int)
    case serverError(Error)
    
    func description() -> String {
        switch self {
        case .none:
            return ""
        case .parseError:
            return "An error occurred when parsing the response"
        case .badRequest(let code):
            return "Bad request according from server. HTTP Code: \(code)"
        case .invalidRequest(let code):
            return "Server could not parse request. HTTP Code: \(code)"
        case .serverError(let res):
            let err = (res as NSError).description
            return "A server error occurred. \(err)"
        }
        
    }
}

open class ApiResponse {
    open var request: ApiRequest
    open var responseBody: String?
    open var error: ApiResponseError?
    open var status: Int?
    open var parsedResponse: Any?
    
    open var isSuccessful: Bool {
        if let status = status {
            return status >= 200 && status <= 299
        } else {
            return false
        }
    }
    
    open var isInvalid: Bool {
        if let status = status {
            return status >= 400 && status <= 499
        } else {
            return true
        }
    }
    
    public init(request: ApiRequest) {
        self.request = request
    }
}
