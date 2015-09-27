//
//  FormDataEncoding.swift
//  ApiModel
//
//  Created by Erik Rothoff Andersson on 2015-26-09.
//
//

import Foundation
import Alamofire

func formDataEncoding(request: URLRequestConvertible, parameters: [String: AnyObject]?) -> (NSMutableURLRequest, NSError?) {
    let boundary = "Boundary-ERIKSAWESOMEBOUNDARYWIEEEEEEEEEEEEEEEEEEE"
    
    let request = request.URLRequest
    
    let fullData = NSMutableData()
    addParametersToData(parameters ?? [:], outputData: fullData, withBoundary: boundary)
    
    fullData.appendData("--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    
    request.HTTPBody = fullData
    request.HTTPShouldHandleCookies = true
    
    request.setValue("multipart/form-data; boundary=" + boundary, forHTTPHeaderField: "Content-Type")
    request.setValue(String(fullData.length), forHTTPHeaderField: "Content-Length")
    
    return (request, nil)
}

public extension ApiRequest {
    public static var FormDataEncoding: ParameterEncoding {
        return ParameterEncoding.Custom(formDataEncoding)
    }
}

func addParametersToData(parameters: [String:AnyObject], outputData: NSMutableData, withBoundary boundary: String, keyPrefix: String = "") {
    let header = "--\(boundary)".dataUsingEncoding(NSUTF8StringEncoding)!
    let footer = "--\(boundary)".dataUsingEncoding(NSUTF8StringEncoding)!
    let sep = "\r\n".dataUsingEncoding(NSUTF8StringEncoding)!
    
    for (key, value) in parameters {
        let formKey: String
        if keyPrefix.isEmpty {
            formKey = "\(keyPrefix)\(key)"
        } else {
            formKey = "\(keyPrefix)[\(key)]"
        }
        
        if let valueData = value as? NSData {
            outputData.appendData(sep)
            outputData.appendData(header)
            outputData.appendData(sep)
            
            outputData.appendData(dataToFormDataField(formKey, data: valueData, boundary: boundary, fileName: "file.jpg", contentType: "image/jpg"))
            
            outputData.appendData(footer)
        } else if let nestedParameters = value as? [String:AnyObject] {
            addParametersToData(nestedParameters, outputData: outputData, withBoundary: boundary, keyPrefix: formKey)
        } else if let arrayData = value as? [AnyObject] {
            
        } else {
            outputData.appendData(sep)
            outputData.appendData(header)
            outputData.appendData(sep)
            
            outputData.appendData(stringToFromDataField(formKey, data: String(value), boundary: boundary))
            
            outputData.appendData(footer)
        }
    }
}

func dataToFormDataField(key: String, data: NSData, boundary: String, fileName: String?, contentType: String?) -> NSData {
    let fullData = NSMutableData()
    
    let fileNameField: String
    if let fileName = fileName {
        fileNameField = "filename=\"\(fileName)\""
    } else {
        fileNameField = ""
    }
    
    let contentTypeField: String
    if let contentType = contentType {
        contentTypeField = "Content-Type: \(contentType)\r\n"
    } else {
        contentTypeField = ""
    }
    
    let header = "Content-Disposition: form-data; name=\"\(key)\"; \(fileNameField)\r\n" +
        "\(contentTypeField)\r\n"
    
    fullData.appendData(header.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
    fullData.appendData(data)
    
    return fullData
}

func stringToFromDataField(key: String, data: String, boundary: String) -> NSData {
    let stringData = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    return dataToFormDataField(key, data: stringData, boundary: boundary, fileName: nil, contentType: nil)
}