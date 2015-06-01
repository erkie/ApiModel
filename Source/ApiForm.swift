import RealmSwift
import Alamofire

// There is a bug in Swift and Realm ~> 0.92 that causes objects that are initialized through a template type
// to crash. Apparently, adding an init method and calling that in the template works around this.
// realm.io bug report: https://github.com/realm/realm-cocoa/issues/1916
extension Object {
    convenience init(completelyBogusInitializerDoesNothing: Bool) {
        self.init()
    }
}

public class ApiFormResponse {
    public var dictionary: [String:AnyObject]?
    public var array: [JSON]?
    public var errors: [String:[String]]?
    
    public var isSuccessful: Bool {
        for (key, errorsForKey) in errors ?? [:] {
            if !errorsForKey.isEmpty {
                return false
            }
        }
        return true
    }
}

public typealias ResponseCallback = (ApiFormResponse) -> Void

public class ApiForm<ModelType:Object where ModelType:ApiTransformable> {
    public var errors: [String:[String]] = [:]
    public var model: ModelType

    public var errorMessages:[String] {
        get {
            var errorString: [String] = []
            for (key, errorsForProperty) in errors {
                for message in errorsForProperty {
                    if key == "base" {
                        errorString.append(message)
                    } else {
                        errorString.append("\(key.capitalizedString) \(message)")
                    }
                }
            }
            return errorString
        }
    }

    public var hasErrors: Bool {
        get {
            return !errors.isEmpty
        }
    }

    public init(model: ModelType) {
        self.model = model
    }

    public func updateFromForm(formParameters: NSDictionary) {
        model.modifyStoredObject {
            self.model.updateFromDictionaryWithMapping(formParameters as! [String:AnyObject], mapping: ModelType.fromJSONMapping())
        }
    }
    
    public func updateFromResponse(responseData: [String:AnyObject]?) {
        if let responseData = responseData {
            model.modifyStoredObject {
                self.model.updateFromDictionaryWithMapping(responseData, mapping: ModelType.fromJSONMapping())
            }
        }
    }

    public class func fromApi(apiResponse: [String:AnyObject]) -> ModelType {
        let newModel = ModelType(completelyBogusInitializerDoesNothing: true)
        newModel.updateFromDictionaryWithMapping(apiResponse, mapping: ModelType.fromJSONMapping())
        return newModel
    }
    
    // api-model style methods
    
    public class func get(path: String, parameters: RequestParameters, callback: ResponseCallback?) {
        let call = ApiCall(method: .GET, path: path, parameters: parameters)
        perform(call, namespace: ModelType.apiNamespace(), callback: callback)
    }
    
    public class func get(path: String, callback: ResponseCallback?) {
        get(path, parameters: [:], callback: callback)
    }
    
    public class func post(path: String, parameters: RequestParameters, callback: ResponseCallback?) {
        let call = ApiCall(method: .POST, path: path, parameters: parameters)
        perform(call, namespace: ModelType.apiNamespace(), callback: callback)
    }
    
    public class func post(path: String, callback: ResponseCallback?) {
        post(path, parameters: [:], callback: callback)
    }
    
    public class func delete(path: String, parameters: RequestParameters, callback: ResponseCallback?) {
        let call = ApiCall(method: .DELETE, path: path, parameters: parameters)
        perform(call, namespace: ModelType.apiNamespace(), callback: callback)
    }
    
    public class func delete(path: String, callback: ResponseCallback?) {
        delete(path, parameters: [:], callback: callback)
    }
    
    public class func put(path: String, parameters: RequestParameters, callback: ResponseCallback?) {
        let call = ApiCall(method: .PUT, path: path, parameters: parameters)
        perform(call, namespace: ModelType.apiNamespace(), callback: callback)
    }
    
    public class func put(path: String, callback: ResponseCallback?) {
        put(path, parameters: [:], callback: callback)
    }
    
    // active record (rails) style methods

    public class func find(callback: (ModelType?) -> Void) {
        let call = ApiCall(
            method: .GET,
            path: ModelType.apiRoutes().index
        )

        perform(call, namespace: ModelType.apiNamespace()) { response in
            if let modelData = response.dictionary {
                let model = self.fromApi(modelData)
                callback(model)
            } else {
                callback(nil)
            }
        }
    }

    public class func findArray(callback: ([ModelType]) -> Void) {
        findArray(ModelType.apiRoutes().index, namespace: ModelType.apiNamespace(), callback: callback)
    }

    public class func findArray(path: String, namespace: String, callback: ([ModelType]) -> Void) {
        let call = ApiCall(
            method: .GET,
            path: path
        )

        perform(call, namespace: namespace) { response in
            if let arrayData = response.array {
                var ret: [ModelType] = []
                
                for modelData in arrayData {
                    let model = self.fromApi(modelData.dictionaryObject!)
                    ret.append(model)
                }
                
                callback(ret)
            } else {
                callback([])
            }
        }
    }
    
    public class func create(parameters: RequestParameters, callback: (ModelType?) -> Void) {
        let call = ApiCall(
            method: .POST,
            path: ModelType.apiRoutes().create,
            parameters: parameters
        )
        
        perform(call, namespace: ModelType.apiNamespace()) { response in
            if let modelData = response.dictionary {
                let model = self.fromApi(modelData)
                callback(model)
            } else {
                callback(nil)
            }
        }
    }
    
    public class func update(parameters: RequestParameters, callback: (ModelType?) -> Void) {
        let call = ApiCall(
            method: .PUT,
            path: ModelType.apiRoutes().update,
            parameters: parameters
        )
        
        perform(call, namespace: ModelType.apiNamespace()) { response in
            if let modelData = response.dictionary {
                let model = self.fromApi(modelData)
                callback(model)
            } else {
                callback(nil)
            }
        }
    }
    
    public func save(callback: (ApiForm) -> Void) {
        var parameters = model.JSONDictionary()

        var path = ModelType.apiRoutes().create
        var method: Alamofire.Method = .POST
        if model.isApiSaved() {
            path = ModelType.apiRoutes().update
            method = .PUT
        }
        
        var call = ApiCall(
            method: method,
            path: model.apiRouteWithReplacements(path),
            parameters: parameters
        )
        
        self.dynamicType.perform(call, namespace: ModelType.apiNamespace()) { response in
            self.updateFromResponse(response.dictionary)
            
            if let errors = response.errors {
                self.errors = errors
            }
            
            callback(self)
        }
    }

    public func reload(callback: (ApiForm) -> Void) {
        var call = ApiCall(
            method: .GET,
            path: model.apiRouteWithReplacements(ModelType.apiRoutes().show)
        )
        
        self.dynamicType.perform(call, namespace: ModelType.apiNamespace()) { response in
            self.updateFromResponse(response.dictionary)
            
            if let errors = response.errors {
                self.errors = errors
            }
            
            callback(self)
        }
    }
    
    public func destroy(callback: (ApiForm) -> Void) {
        destroy([:], callback: callback)
    }
    
    public func destroy(parameters: RequestParameters, callback: (ApiForm) -> Void) {
        var call = ApiCall(
            method: .DELETE,
            path: model.apiRouteWithReplacements(ModelType.apiRoutes().destroy),
            parameters: parameters
        )
        
        self.dynamicType.perform(call, namespace: ModelType.apiNamespace()) { response in
            self.updateFromResponse(response.dictionary)
            
            if let errors = response.errors {
                self.errors = errors
            }
            
            callback(self)
        }
    }

    public class func perform(call: ApiCall, namespace: String, callback: ResponseCallback?) {
        api().request(
            call.method,
            path: call.path,
            parameters: call.parameters
        ) { (data, error) in
            var response = ApiFormResponse()
            
            if let responseObject = self.objectFromResponseForNamespace(data, namespace: namespace) {
                response.dictionary = responseObject
                
                if let errors = self.errorFromResponse(responseObject, error: error) {
                    response.errors = errors
                }
            } else if let arrayData = self.arrayFromResponseForNamespace(data, namespace: namespace) {
                response.array = arrayData
            }
            
            callback?(response)
        }
    }
    
    private class func objectFromResponseForNamespace(data: JSON, namespace: String) -> [String:AnyObject]? {
        return data[namespace].dictionaryObject ?? data[namespace.pluralize()].dictionaryObject
    }
    
    private class func arrayFromResponseForNamespace(data: JSON, namespace: String) -> [JSON]? {
        return data[namespace].array ?? data[namespace.pluralize()].array
    }
    
    private class func errorFromResponse(response: [String:AnyObject]?, error: NSError?) -> [String:[String]]? {
        if let errors = response?["errors"] as? [String:[String]] {
            return errors
        } else if error != nil {
            return ["base": ["An unexpected server error occurred"]]
        } else {
            return nil
        }
    }
}
