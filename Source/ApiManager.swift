import Foundation
import Alamofire

open class ApiManager {
    open var config: ApiConfig
    
    open var beforeRequestHooks: [((ApiRequest) -> Void)] = []
    open var afterRequestHooks: [((ApiRequest, ApiResponse) -> Void)] = []
    
    fileprivate var alamoFireManager : Alamofire.SessionManager
    
    public init(config: ApiConfig) {
        self.config = config
        
        if let sessionConfig = config.urlSessionConfig {
            self.alamoFireManager = Alamofire.SessionManager(configuration: sessionConfig)
        }else{
            self.alamoFireManager = Alamofire.SessionManager.default
        }
        
        beforeRequest { request in
            if self.config.requestLogging {
                request.userInfo["requestStartedAt"] = Date() as Any?
                
                print("ApiModel: \(request.method) \(request.path) with headers: \(request.headers)")
            }
        }
        
        afterRequest { request, response in
            if self.config.requestLogging {
                let duration: String
                if let requestStartedAt = request.userInfo["requestStartedAt"] as? Date {
                    let formatter = NumberFormatter()
                    formatter.minimumFractionDigits = 2
                    formatter.maximumFractionDigits = 2
                    formatter.minimumIntegerDigits = 1
                    
                    let requestDuration = Date().timeIntervalSince(requestStartedAt)
                    duration = formatter.string(from: requestDuration as NSNumber) ?? "\(requestDuration)"
                } else {
                    duration = "?"
                }
                
                print("ApiModel: \(request.method) \(request.path) finished in \(duration) seconds with status \(response.status ?? 0)")
                
                if let error = response.error {
                    print("... Error \(error.description())")
                }
            }
        }
    }
    
    open func request(
        _ method: Alamofire.HTTPMethod,
        path: String,
        parameters: [String: Any] = [:],
        headers: [String: String] = [:],
        apiConfig: ApiConfig,
        responseHandler: @escaping (ApiResponse?, ApiResponseError?) -> Void
    ) {
        let parser = apiConfig.parser
        
        let request = ApiRequest(
            config: apiConfig,
            method: method,
            path: path
        )
        
        request.parameters = parameters
        request.headers = headers
        
        for hook in beforeRequestHooks {
            hook(request)
        }
        
        performRequest(request) { response in
            parser.parse(response.responseBody ?? "") { parsedResponse in
                let (finalResponse, errors) = self.handleResponse(
                    response,
                    parsedResponse: parsedResponse,
                    apiConfig: apiConfig
                )
                
                responseHandler(finalResponse, errors)
            }
        }
    }
    
    open func handleResponse(
        _ response: ApiResponse,
        parsedResponse: Any?,
        apiConfig: ApiConfig
    ) -> (ApiResponse?, ApiResponseError?) {
        // if response is either nil or NSNull and the request was not 200 it is an error
        if (parsedResponse == nil || (parsedResponse as? NSNull) != nil) && !response.isSuccessful {
            response.error = ApiResponseError.badRequest(code: response.status ?? 0)
        }
        
        if response.isInvalid {
            response.error = ApiResponseError.invalidRequest(code: response.status ?? 0)
        }
        
        response.parsedResponse = parsedResponse
        if let nestedResponse = parsedResponse as? [String:Any], !apiConfig.rootNamespace.isEmpty {
            response.parsedResponse = fetchPathFromDictionary(apiConfig.rootNamespace, dictionary: nestedResponse)
        } else {
            response.parsedResponse = parsedResponse
        }
        
        return (response, response.error)
    }
    
    func performRequest(_ request: ApiRequest, responseHandler: @escaping (ApiResponse) -> Void) {
        let response = ApiResponse(request: request)
        
        self.alamoFireManager.request(
            request.url,
            method: request.method,
            parameters: request.parameters,
            encoding: request.encoding,
            headers: request.headers
        )
        .responseString { alamofireResponse in
            response.responseBody = alamofireResponse.result.value
            if let error = alamofireResponse.result.error {
                response.error = ApiResponseError.serverError(error)
            }
            response.status = alamofireResponse.response?.statusCode
            
            for hook in self.afterRequestHooks {
                hook(request, response)
            }
            
            responseHandler(response)
        }
    }
    
    open func beforeRequest(_ hook: @escaping ((ApiRequest) -> Void)) {
        beforeRequestHooks.insert(hook, at: 0)
    }
    
    open func afterRequest(_ hook: @escaping ((ApiRequest, ApiResponse) -> Void)) {
        afterRequestHooks.append(hook)
    }
}

public struct ApiSingleton {
    public static var instance: ApiManager = ApiManager(config: ApiConfig())
    
    public static func setInstance(_ apiInstance: ApiManager) {
        instance = apiInstance
    }
}

public func apiManager() -> ApiManager {
    return ApiSingleton.instance
}
