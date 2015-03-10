//
//  ApiForm.swift
//  APIModel
//
//  Copyright (c) 2015 Rootof Creations HB. All rights reserved.
//

import Realm
import Alamofire

public class ApiForm<ModelType:RLMObject where ModelType:ApiTransformable> {
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
    
    public class func fromApi(apiResponse: JSON) -> ModelType {
        let newModel = ModelType()
        newModel.updateFromDictionaryWithMapping(apiResponse.dictionaryObject!, mapping: ModelType.fromJSONMapping())
        return newModel
    }
    
    public class func load(callback: (ModelType?) -> Void) {
        find(call: ApiCall(), callback: callback)
    }
    
    public class func find(call: ApiCall = ApiCall(), callback: (ModelType?) -> Void) {
        call.provideDefaults(ModelType)
        
        api().GET(call.resource!, parameters: [:]) { data, error in
            if data[call.namespace!] != nil {
                let modelData = data[call.namespace!]
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
        
        api().GET(call.resource!, parameters: [:]) { data, error in
            if let arrayData = data[call.namespace!].array {
                var ret: [ModelType] = []
                
                for modelData in arrayData {
                    let model = self.fromApi(modelData)
                    ret.append(model)
                }
                
                callback(ret)
            } else {
                callback([])
            }
        }
    }

    public class func post(parameters: [String:AnyObject], callback: (ModelType?) -> Void) {
        api().POST(ModelType.apiResource().create, parameters: parameters) { (data, error) in
            if data[ModelType.apiNamespace()] != nil {
                let modelData = data[ModelType.apiNamespace()]
                
                let model = self.fromApi(modelData)
                callback(model)
            } else {
                callback(nil)
            }
        }
    }

    public func save(callback: (ApiForm) -> Void) {
        var parameters = model.JSONDictionary()
        
        var apiResource = ModelType.apiResource().create
        var method: Alamofire.Method = .POST
        if model.isApiSaved() {
            apiResource = ModelType.apiResource().update
            method = .PUT
        }
        
        api().runRequest(method, path: model.apiResourceWithReplacements(apiResource), parameters: [ModelType.apiNamespace(): parameters]) { (data, error) in
            if let responseData = data[ModelType.apiNamespace()].dictionaryObject {
                self.model.modifyStoredObject {
                    self.model.updateFromDictionaryWithMapping(responseData, mapping: ModelType.fromJSONMapping())
                }
            }
            
            if let errors = data[ModelType.apiNamespace()]["errors"].dictionary {
                self.errors = JSONtoDictionary(errors)
            } else if error != nil {
                self.errors = ["base": ["An unexpected server error occurred"]]
            }
            
            callback(self)
        }
    }
    
    public func reload(callback: (ApiForm) -> Void) {
        var parameters = model.JSONDictionary()
        
        api().GET(model.apiResourceWithReplacements(ModelType.apiResource().show), parameters: [:]) { (data, error) in
            if let responseData = data[ModelType.apiNamespace()].dictionaryObject {
                self.model.modifyStoredObject {
                    self.model.updateFromDictionaryWithMapping(responseData, mapping: ModelType.fromJSONMapping())
                }
            }
            
            if let errors = data[ModelType.apiNamespace()]["errors"].dictionary {
                self.errors = JSONtoDictionary(errors)
            } else if error != nil {
                self.errors = ["base": ["An unexpected server error occurred"]]
            }
            
            callback(self)
        }
    }
}