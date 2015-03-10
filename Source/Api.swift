//
//  API.swift
//  APIModel
//
//  Copyright (c) 2015 Rootof Creations HB. All rights reserved.
//

import Foundation
import Alamofire

public class API {
    public var configuration: ApiConfiguration
    
    public var beforeRequestHooks: [((APIRequest) -> Void)] = []
    public var afterRequestHooks: [((APIRequest, APIResponse) -> Void)] = []
    
    public init(configuration: ApiConfiguration) {
        self.configuration = configuration
    }
    
    public func GET(path: String, var parameters: [String : AnyObject] = [:], responseHandler: (JSON, NSError?) -> Void) {
        runRequest(.GET, path: path, parameters: parameters, responseHandler: responseHandler)
    }
    
    public func POST(path: String, var parameters: [String : AnyObject] = [:], responseHandler: (JSON, NSError?) -> Void) {
        runRequest(.POST, path: path, parameters: parameters, responseHandler: responseHandler)
    }
    
    public func PUT(path: String, var parameters: [String : AnyObject] = [:], responseHandler: (JSON, NSError?) -> Void) {
        runRequest(.PUT, path: path, parameters: parameters, responseHandler: responseHandler)
    }
    
    public func runRequest(method: Alamofire.Method, path: String, var parameters: [String : AnyObject] = [:], responseHandler: (JSON, NSError?) -> Void) {
        var request = APIRequest(method: method, path: path)
        request.parameters = parameters
        
        for hook in beforeRequestHooks {
            hook(request)
        }
        
        performRequest(request) { response in
            responseHandler(response.json ?? JSON([:]), response.error)
            return
        }
    }
    
    func performRequest(request: APIRequest, responseHandler: (APIResponse) -> Void) {
        var response = APIResponse(request: request)
        
        Alamofire.request(request.method, request.url, parameters: request.parameters)
            .responseSwiftyJSON(completionHandler: { (_, alamofireResponse, data, error) in
                response.json = data
                response.error = error
                response.status = alamofireResponse?.statusCode
                
                for hook in self.afterRequestHooks {
                    hook(request, response)
                }
                
                responseHandler(response)
            })
    }
    
    public func beforeRequest(hook: ((APIRequest) -> Void)) {
        beforeRequestHooks.append(hook)
    }
    
    public func afterRequest(hook: ((APIRequest, APIResponse) -> Void)) {
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

