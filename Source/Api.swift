import Foundation
import Alamofire

public class API {
    public var configuration: ApiConfiguration

    public var beforeRequestHooks: [((ApiRequest) -> Void)] = []
    public var afterRequestHooks: [((ApiRequest, ApiResponse) -> Void)] = []

    public init(configuration: ApiConfiguration) {
        self.configuration = configuration
    }

    public func request(method: Alamofire.Method, path: String, parameters: [String : AnyObject] = [:], responseHandler: (AnyObject?, NSError?) -> Void) {
        let configuration = api().configuration
        
        var request = ApiRequest(configuration: configuration, method: method, path: path)
        request.parameters = parameters

        for hook in beforeRequestHooks {
            hook(request)
        }

        performRequest(request) { response in
            configuration.parser.parse(response.responseBody ?? "") { parsedResponse in
                responseHandler(parsedResponse, response.error)
            }
        }
    }

    func performRequest(request: ApiRequest, responseHandler: (ApiResponse) -> Void) {
        var response = ApiResponse(request: request)
        let requestStartedAt = NSDate()

        if configuration.requestLogging {
            NSLog("ApiModel: \(request.method.rawValue) \(request.url) with params: \(request.parameters)")
        }

        Alamofire.request(request.method, request.url, parameters: request.parameters)
            .responseString { _, alamofireResponse, responseBody, error in
                response.responseBody = responseBody
                response.error = error
                response.status = alamofireResponse?.statusCode

                if self.configuration.requestLogging {
                    NSLog("ApiModel: \(request.method.rawValue) \(request.url) finished in %.2fs with status \(response.status!)", NSDate().timeIntervalSinceDate(requestStartedAt))
                }

                for hook in self.afterRequestHooks {
                    hook(request, response)
                }

                responseHandler(response)
            }
    }

    public func beforeRequest(hook: ((ApiRequest) -> Void)) {
        beforeRequestHooks.append(hook)
    }

    public func afterRequest(hook: ((ApiRequest, ApiResponse) -> Void)) {
        afterRequestHooks.append(hook)
    }
}

public struct ApiSingleton {
    static var instance: API = API(configuration: ApiConfiguration())

    public static func setInstance(apiInstance: API) {
        instance = apiInstance
    }
}

public func api() -> API {
    return ApiSingleton.instance
}

