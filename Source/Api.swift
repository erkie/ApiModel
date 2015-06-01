import Foundation
import Alamofire

public class API {
    public var configuration: ApiConfiguration

    public var beforeRequestHooks: [((ApiRequest) -> Void)] = []
    public var afterRequestHooks: [((ApiRequest, ApiResponse) -> Void)] = []

    public init(configuration: ApiConfiguration) {
        self.configuration = configuration
    }

    public func request(method: Alamofire.Method, path: String, var parameters: [String : AnyObject] = [:], responseHandler: (JSON, NSError?) -> Void) {
        var request = ApiRequest(configuration: api().configuration, method: method, path: path)
        request.parameters = parameters

        for hook in beforeRequestHooks {
            hook(request)
        }

        performRequest(request) { response in
            responseHandler(response.json ?? JSON([:]), response.error)
            return
        }
    }

    func performRequest(request: ApiRequest, responseHandler: (ApiResponse) -> Void) {
        var response = ApiResponse(request: request)
        let requestStartedAt = NSDate()

        if configuration.requestLogging {
            NSLog("ApiModel: \(request.method.rawValue) \(request.url) with params: \(request.parameters)")
        }

        Alamofire.request(request.method, request.url, parameters: request.parameters)
            .responseSwiftyJSON(completionHandler: { (_, alamofireResponse, data, error) in
                response.json = data
                response.error = error
                response.status = alamofireResponse?.statusCode

                if self.configuration.requestLogging {
                    NSLog("ApiModel: \(request.method.rawValue) \(request.url) finished in %.2fs with status \(response.status!)", NSDate().timeIntervalSinceDate(requestStartedAt))
                }

                for hook in self.afterRequestHooks {
                    hook(request, response)
                }

                responseHandler(response)
            })
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

