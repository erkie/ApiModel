//
//  FormDataEncoding.swift
//  ApiModel
//
//  Created by Erik Rothoff Andersson on 2015-26-09.
//
//

import Foundation
import Alamofire

public class FileUpload {
    public var fileName: String
    public var mimeType: String
    public var data: NSData
    
    public init(fileName: String, mimeType: String, data: NSData) {
        self.fileName = fileName
        self.mimeType = mimeType
        self.data = data
    }
}

func formDataEncoding(request: URLRequestConvertible, parameters: [String: AnyObject]?) -> (NSMutableURLRequest, NSError?) {
    let request = request.URLRequest
    
    let formData = MultipartFormData()
    
    addParametersToData(parameters ?? [:], formData: formData)
    
    let fullData: NSData
    do {
        fullData = try formData.encode()
    } catch let error as NSError {
        return (request, error)
    }
    
    request.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")
    request.setValue(String(formData.contentLength), forHTTPHeaderField: "Content-Length")
    
    request.HTTPBody = fullData
    request.HTTPShouldHandleCookies = true
    
    return (request, nil)
}

public extension ApiRequest {
    public static var FormDataEncoding: ParameterEncoding {
        return ParameterEncoding.Custom(formDataEncoding)
    }
}

func addParametersToData(parameters: [String:AnyObject], formData: MultipartFormData, keyPrefix: String = "") {
    for (key, value) in parameters {
        let formKey = keyPrefix.isEmpty ? key : "\(keyPrefix)[\(key)]"
        
        // FileUpload
        if let fileUpload = value as? FileUpload {
            formData.appendBodyPart(data: fileUpload.data, name: formKey, fileName: fileUpload.fileName, mimeType: fileUpload.mimeType)
        // NSData
        } else if let valueData = value as? NSData {
            formData.appendBodyPart(data: valueData, name: formKey, fileName: "data.dat", mimeType: "application/octet-stream")
        // Nested hash
        } else if let nestedParameters = value as? [String:AnyObject] {
            addParametersToData(nestedParameters, formData: formData, keyPrefix: formKey)
        // Nested array
        } else if let arrayData = value as? [AnyObject] {
            var asHash: [String:AnyObject] = [:]
            
            for (index, arrayValue) in arrayData.enumerate() {
                asHash[String(index)] = arrayValue
            }
            
            addParametersToData(asHash, formData: formData, keyPrefix: formKey)
        // Anything else, cast it to a string
        } else if let dataString = String(value).dataUsingEncoding(NSUTF8StringEncoding) {
            formData.appendBodyPart(data: dataString, name: key)
        }
    }
}
