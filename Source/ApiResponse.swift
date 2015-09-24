import Foundation

public enum ApiResponseError: ErrorType {
    case None
    case ParseError
    case BadRequest(code: Int)
    case InvalidRequest(code: Int)
    case ServerError(ErrorType)
    
    func description() -> String {
        switch self {
        case .None:
            return ""
        case .ParseError:
            return "An error occurred when parsing the response"
        case .BadRequest(let code):
            return "Bad request according from server. HTTP Code: \(code)"
        case .InvalidRequest(let code):
            return "Server could not parse request. HTTP Code: \(code)"
        case .ServerError(let res):
            let err = (res as NSError).description
            return "A server error occurred. \(err)"
        }
        
    }
}

public class ApiResponse {
    public var request: ApiRequest
    public var responseBody: String?
    public var error: ApiResponseError?
    public var status: Int?
    public var parsedResponse: AnyObject?
    
    public var isSuccessful: Bool {
        if let status = status {
            return status >= 200 && status <= 299
        } else {
            return false
        }
    }
    
    public var isInvalid: Bool {
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
