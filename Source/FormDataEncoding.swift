//
//  FormDataEncoding.swift
//  ApiModel
//
//  Created by Erik Rothoff Andersson on 2015-26-09.
//
//

import Foundation
import Alamofire

open class FileUpload {
    open var fileName: String
    open var mimeType: String
    open var data: Data
    
    public init(fileName: String, mimeType: String, data: Data) {
        self.fileName = fileName
        self.mimeType = mimeType
        self.data = data
    }
}

open class FormDataEncoding: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
    
        let formData = MultipartFormData()
        
        addParametersToData(parameters ?? [:], formData: formData)
        
        let fullData = try formData.encode()
        
        request.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(String(formData.contentLength), forHTTPHeaderField: "Content-Length")
        
        request.httpBody = fullData
        request.httpShouldHandleCookies = true
        
        return request
    }
}

func addParametersToData(_ parameters: [String:Any], formData: MultipartFormData, keyPrefix: String = "") {
    for (key, value) in parameters {
        let formKey = keyPrefix.isEmpty ? key : "\(keyPrefix)[\(key)]"
        
        // FileUpload
        if let fileUpload = value as? FileUpload {
            formData.append(fileUpload.data, withName: formKey, fileName: fileUpload.fileName, mimeType: fileUpload.mimeType)
        // NSData
        } else if let valueData = value as? Data {
            formData.append(valueData, withName: formKey, fileName: "data.dat", mimeType: "application/octet-stream")
        // Nested hash
        } else if let nestedParameters = value as? [String:AnyObject] {
            addParametersToData(nestedParameters, formData: formData, keyPrefix: formKey)
        // Nested array
        } else if let arrayData = value as? [AnyObject] {
            var asHash: [String:AnyObject] = [:]
            
            for (index, arrayValue) in arrayData.enumerated() {
                asHash[String(index)] = arrayValue
            }
            
            addParametersToData(asHash, formData: formData, keyPrefix: formKey)
        // Anything else, cast it to a string
        } else if let dataString = String(describing: value).data(using: String.Encoding.utf8) {
            formData.append(dataString, withName: key)
        }
    }
}
