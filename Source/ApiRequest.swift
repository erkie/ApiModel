//
//  ApiRequest.swift
//  APIModel
//
//  Created by Erik Rothoff Andersson on 03/05/15.
//
//

import Alamofire

public class APIRequest {
    public var path: String
    public var parameters: [String:AnyObject] = [:]
    public var method: Alamofire.Method
    
    public init(method: Alamofire.Method, path: String) {
        self.method = method
        self.path = path
    }
    
    public var url: String {
        get {
            return api().configuration.host + path
        }
    }
}