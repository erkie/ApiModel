import RealmSwift
import Alamofire

public enum ApiModelStatus {
    case none
    case successful(Int)
    case unauthorized(Int)
    case invalid(Int)
    case serverError(Int)
    
    init(statusCode: Int) {
        if statusCode >= 200 && statusCode <= 299 {
            self = .successful(statusCode)
        } else if statusCode == 401 {
            self = .unauthorized(statusCode)
        } else if statusCode >= 400 && statusCode <= 499 {
            self = .invalid(statusCode)
        } else if statusCode >= 500 && statusCode <= 599 {
            self = .serverError(statusCode)
        } else {
            self = .none
        }
    }
}

open class ApiModelResponse<ModelType:Object> where ModelType:ApiModel {
    open var responseData: [String:Any]?
    open var responseObject: [String:Any]?
    open var responseArray: [Any]?
    open var errors: [String:[String]]?
    open var rawResponse: ApiResponse?
    
    open var isSuccessful: Bool {
        for (_, errorsForKey) in errors ?? [:] {
            if !errorsForKey.isEmpty {
                return false
            }
        }
        return true
    }
    
    open var responseStatus: ApiModelStatus {
        if let status = rawResponse?.status {
            return ApiModelStatus(statusCode: status)
        } else {
            return .none
        }
    }
    
    public var errorMessages: [String]? {
        if let errors = errors {
            var messages: [String] = []
            for nestedErrors in errors.values {
                messages.append(contentsOf: nestedErrors)
            }
            return messages
        } else {
            return nil
        }
    }
    
    var _object: ModelType?
    var _parsedObject = false
    
    open var object: ModelType? {
        if _parsedObject {
            return _object
        }
        
        _parsedObject = true
        
        if let responseObject = responseObject {
            _object = fromApi(responseObject)
        }
        
        return _object
    }
    
    var _array: [ModelType]? = nil
    var _parsedArray = false
    
    open var array: [ModelType]? {
        if _parsedArray {
            return _array
        }
        _parsedArray = true
        
        if let arrayData = responseArray {
            _array = []
            
            for modelData in arrayData {
                if let modelDictionary = modelData as? [String:Any] {
                    _array!.append(fromApi(modelDictionary))
                }
            }
        }
        
        return _array
    }
    
    func fromApi(_ apiResponse: [String:Any]) -> ModelType {
        let newModel = ModelType()
        newModel.updateFromDictionary(apiResponse)
        return newModel
    }
}

open class Api<ModelType:Object> where ModelType:ApiModel {
    public typealias ResponseCallback = (ApiModelResponse<ModelType>) -> Void
    
    open var apiConfig: ApiConfig
    open var status: ApiModelStatus = .none
    open var errors: [String:[String]] = [:]
    open var model: ModelType
    
    open var errorMessages:[String] {
        var errorString: [String] = []
        for (key, errorsForProperty) in errors {
            for message in errorsForProperty {
                if key == "base" {
                    errorString.append(message)
                } else {
                    errorString.append("\(key.capitalized) \(message)")
                }
            }
        }
        return errorString
    }
    
    open var hasErrors: Bool {
        return !errors.isEmpty
    }
    
    public required init(model: ModelType, apiConfig: ApiConfig) {
        self.model = model
        self.apiConfig = apiConfig
    }
    
    public convenience init(model: ModelType) {
        self.init(model: model, apiConfig: type(of: self).apiConfigForType())
    }
    
    public static func apiConfigForType() -> ApiConfig {
        if let configurable = ModelType.self as? ApiConfigurable.Type {
            return configurable.apiConfig(apiManager().config.copy())
        } else {
            return apiManager().config
        }
    }
    
    open func updateFromForm(_ formParameters: NSDictionary) {
        model.modifyStoredObject {
            self.model.updateFromDictionary(formParameters as! [String:Any])
        }
    }
    
    open func updateFromResponse(_ response: ApiModelResponse<ModelType>) {
        if let statusCode = response.rawResponse?.status {
            self.status = ApiModelStatus(statusCode: statusCode)
        }
        
        if let responseObject = response.responseObject {
            model.modifyStoredObject {
                self.model.updateFromDictionary(responseObject)
            }
        }
        
        if let errors = response.errors {
            self.errors = errors
        }
    }
    
    // api-model style methods
    
    open class func performWithMethod(_ method: Alamofire.HTTPMethod, path: String, parameters: RequestParameters, apiConfig: ApiConfig, callback: ResponseCallback?) {
        let call = ApiCall(method: method, path: path, parameters: parameters, namespace: ModelType.apiNamespace())
        perform(call, apiConfig: apiConfig, callback: callback)
    }
    
    // GET
    open class func get(_ path: String, parameters: RequestParameters, apiConfig: ApiConfig, callback: ResponseCallback?) {
        performWithMethod(.get, path: path, parameters: parameters, apiConfig: apiConfig, callback: callback)
    }
    
    open class func get(_ path: String, parameters: RequestParameters, callback: ResponseCallback?) {
        get(path, parameters: parameters, apiConfig: apiConfigForType(), callback: callback)
    }
    
    open class func get(_ path: String, callback: ResponseCallback?) {
        get(path, parameters: [:], callback: callback)
    }
    
    // POST
    open class func post(_ path: String, parameters: RequestParameters, apiConfig: ApiConfig, callback: ResponseCallback?) {
        performWithMethod(.post, path: path, parameters: parameters, apiConfig: apiConfig, callback: callback)
    }
    
    open class func post(_ path: String, parameters: RequestParameters, callback: ResponseCallback?) {
        post(path, parameters: parameters, apiConfig: apiConfigForType(), callback: callback)
    }
    
    open class func post(_ path: String, callback: ResponseCallback?) {
        post(path, parameters: [:], callback: callback)
    }
    
    // DELETE
    open class func delete(_ path: String, parameters: RequestParameters, apiConfig: ApiConfig, callback: ResponseCallback?) {
        performWithMethod(.delete, path: path, parameters: parameters, apiConfig: apiConfig, callback: callback)
    }
    
    open class func delete(_ path: String, parameters: RequestParameters, callback: ResponseCallback?) {
        delete(path, parameters: parameters, apiConfig: apiConfigForType(), callback: callback)
    }
    
    open class func delete(_ path: String, callback: ResponseCallback?) {
        delete(path, parameters: [:], callback: callback)
    }
    
    // PUT
    open class func put(_ path: String, parameters: RequestParameters, apiConfig: ApiConfig, callback: ResponseCallback?) {
        performWithMethod(.put, path: path, parameters: parameters, apiConfig: apiConfig, callback: callback)
    }
    
    open class func put(_ path: String, parameters: RequestParameters, callback: ResponseCallback?) {
        put(path, parameters: parameters, apiConfig: apiConfigForType(), callback: callback)
    }
    
    open class func put(_ path: String, callback: ResponseCallback?) {
        put(path, parameters: [:], callback: callback)
    }
    
    // active record (rails) style methods
    
    open class func find(_ callback: @escaping (ModelType?, ApiModelResponse<ModelType>) -> Void) {
        get(ModelType.apiRoutes().index) { response in
            callback(response.object, response)
        }
    }

    open class func findArray(_ callback: @escaping ([ModelType], ApiModelResponse<ModelType>) -> Void) {
        findArray(ModelType.apiRoutes().index, callback: callback)
    }
    
    open class func findArray(_ path: String, callback: @escaping ([ModelType], ApiModelResponse<ModelType>) -> Void) {
        get(path) { response in
            callback(response.array ?? [], response)
        }
    }

    open class func create(_ parameters: RequestParameters, callback: @escaping (ModelType?, ApiModelResponse<ModelType>) -> Void) {
        post(ModelType.apiRoutes().create, parameters: parameters) { response in
            callback(response.object, response)
        }
    }

    open class func update(_ parameters: RequestParameters, callback: @escaping (ModelType?, ApiModelResponse<ModelType>) -> Void) {
        put(ModelType.apiRoutes().update, parameters: parameters) { response in
            callback(response.object, response)
        }
    }
    
    open func save(_ callback: @escaping (Api) -> Void) {
        let parameters: [String: Any] = [
            ModelType.apiNamespace(): model.JSONDictionary() as Any
        ]
        
        let responseCallback: ResponseCallback = { response in
            self.updateFromResponse(response)
            callback(self)
        }
        
        if model.isApiSaved() {
            type(of: self).put(model.apiRouteWithReplacements(ModelType.apiRoutes().update), parameters: parameters as RequestParameters, callback: responseCallback)
        } else {
            type(of: self).post(model.apiRouteWithReplacements(ModelType.apiRoutes().create), parameters: parameters as RequestParameters, callback: responseCallback)
        }
    }
    
    open func destroy(_ callback: @escaping (Api) -> Void) {
        destroy([:], callback: callback)
    }
    
    open func destroy(_ parameters: RequestParameters, callback: @escaping (Api) -> Void) {
        type(of: self).delete(model.apiRouteWithReplacements(ModelType.apiRoutes().destroy), parameters: parameters) { response in
            self.updateFromResponse(response)
            callback(self)
        }
    }
    
    open class func perform(_ call: ApiCall, apiConfig: ApiConfig, callback: ResponseCallback?) {
        apiManager().request(
            call.method,
            path: call.path,
            parameters: call.parameters,
            apiConfig: apiConfig
        ) { data, error in
            let response = ApiModelResponse<ModelType>()
            response.rawResponse = data
            
            if let errors = self.errorFromResponse(nil, error: error) {
                response.errors = errors
            }
            
            if let data: Any = data?.parsedResponse {
                response.responseData = data as? [String:Any]
                
                if let responseObject = self.objectFromResponseForNamespace(data, namespace: call.namespace) {
                    response.responseObject = responseObject
                    
                    if let errors = self.errorFromResponse(responseObject, error: error) {
                        response.errors = errors
                    }
                } else if let arrayData = self.arrayFromResponseForNamespace(data, namespace: call.namespace) {
                    response.responseArray = arrayData
                }
            }
            
            callback?(response)
        }
    }
    
    fileprivate class func objectFromResponseForNamespace(_ data: Any, namespace: String) -> [String:Any]? {
        if let asMap = data as? [String:Any] {
            return (asMap[namespace] as? [String:Any]) ?? (asMap[namespace.pluralize()] as? [String:Any])
        } else {
            return nil
        }
    }
    
    fileprivate class func arrayFromResponseForNamespace(_ data: Any, namespace: String) -> [Any]? {
        if let asMap = data as? [String:Any] {
            return (asMap[namespace] as? [Any]) ?? (asMap[namespace.pluralize()] as? [Any])
        } else {
            return nil
        }
    }
    
    fileprivate class func errorFromResponse(_ response: [String:Any]?, error: ApiResponseError?) -> [String:[String]]? {
        if let errors = response?["errors"] as? [String:[String]] {
            return errors
        } else if let errors = response?["errors"] as? [String] {
            return ["base": errors]
        } else if error != nil {
            return ["base": ["An unexpected server error occurred"]]
        } else {
            return nil
        }
    }
}
