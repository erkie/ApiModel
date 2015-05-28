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

    public class func find(call: ApiCall = ApiCall(), callback: (ModelType?) -> Void) {
        call.provideDefaults(ModelType)

        perform(
            .GET,
            path: call.resource!,
            parameters: [:],
            namespace: ModelType.apiNamespace()
        ) { dictionaryResponse, arrayResponse, errors in
            if let modelData = dictionaryResponse {
                let model = self.fromApi(modelData)
                callback(model)
            } else {
                callback(nil)
            }
        }
    }

    public class func findArray(callback: ([ModelType]) -> Void) {
        return findArray(ApiCall(), callback: callback)
    }

    public class func findArray(call: ApiCall, callback: ([ModelType]) -> Void) {
        call.provideDefaults(ModelType)

        perform(
            .GET,
            path: call.resource!,
            parameters: [:],
            namespace: call.namespace!
        ) { dictionaryResponse, arrayResponse, errors in
            if let arrayData = arrayResponse {
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

    public class func post(parameters: [String:AnyObject], callback: (ModelType?) -> Void) {
        perform(
            .POST,
            path: ModelType.apiRoutes().create,
            parameters: parameters,
            namespace: ModelType.apiNamespace()
        ) { dictionaryResponse, arrayResponse, errors in
            if let modelData = dictionaryResponse {
                let model = self.fromApi(modelData)
                callback(model)
            } else {
                callback(nil)
            }
        }
    }
    
    public func save(callback: (ApiForm) -> Void) {
        var parameters = model.JSONDictionary()

        var apiRoutes = ModelType.apiRoutes().create
        var method: Alamofire.Method = .POST
        if model.isApiSaved() {
            apiRoutes = ModelType.apiRoutes().update
            method = .PUT
        }
        
        self.dynamicType.perform(
            method,
            path: model.apiRouteWithReplacements(apiRoutes),
            parameters: [ModelType.apiNamespace(): parameters],
            namespace: ModelType.apiNamespace()
        ) { dictionaryResponse, arrayResponse, errors in
            self.updateFromResponse(dictionaryResponse)
            
            if let errors = errors {
                self.errors = errors
            }
            
            callback(self)
        }
    }

    public func reload(callback: (ApiForm) -> Void) {
        self.dynamicType.perform(
            .GET,
            path: model.apiRouteWithReplacements(ModelType.apiRoutes().show),
            parameters: [:],
            namespace: ModelType.apiNamespace()
        ) { dictionaryResponse, arrayResponse, errors in
            self.updateFromResponse(dictionaryResponse)
            
            if let errors = errors {
                self.errors = errors
            }
            
            callback(self)
        }
    }
    
    public func destroy(callback: (ApiForm) -> Void) {
        self.dynamicType.perform(
            .DELETE,
            path: ModelType.apiRoutes().destroy,
            parameters: [:],
            namespace: ModelType.apiNamespace()
        ) { dictionaryResponse, arrayResponse, errors in
            self.updateFromResponse(dictionaryResponse)
            callback(self)
        }
    }

    private class func perform(
        method: Alamofire.Method,
        path: String,
        parameters: [String:AnyObject],
        namespace: String,
        callback: ([String:AnyObject]?, [JSON]?, [String:[String]]?) -> Void
    ) {
        api().runRequest(method, path: path, parameters: parameters) { (data, error) in
            if let responseObject = self.objectFromResponseForNamespace(data, namespace: namespace) {
                if let errors = self.errorFromResponse(responseObject, error: error) {
                    callback(responseObject, nil, errors)
                } else {
                    callback(responseObject, nil, nil)
                }
            } else if let arrayData = self.arrayFromResponseForNamespace(data, namespace: namespace) {
                callback(nil, arrayData, nil)
            } else {
                callback(nil, nil, nil)
            }
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
