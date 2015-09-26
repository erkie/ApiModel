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
    return (request.URLRequest, nil)
}

public extension ApiRequest {
    public static var FormDataEncoding: ParameterEncoding {
        return ParameterEncoding.Custom(formDataEncoding)
    }
}