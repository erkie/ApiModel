//
//  JSONParser.swift
//  ApiModel
//
//  Created by Erik Rothoff Andersson on 01/06/15.
//
//

import Foundation
import SwiftyJSON

open class JSONParser: ApiParser {
    open func parse(_ responseString: String, completionHandler: @escaping (AnyObject?) -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
            
            var responseJSON: JSON
            if responseString.isEmpty {
                responseJSON = JSON.null
            } else {
                if let data = (responseString as NSString).data(using: String.Encoding.utf8.rawValue) {
                    do {
                        responseJSON = try SwiftyJSON.JSON(data: data)
                    } catch {
                        responseJSON = JSON.null
                    }
                } else {
                    responseJSON = JSON.null
                }
            }
            
            DispatchQueue.main.async(execute: {
                if let dictionary = responseJSON.dictionaryObject {
                    completionHandler(dictionary as AnyObject?)
                } else if let array = responseJSON.arrayObject {
                    completionHandler(array as AnyObject?)
                } else {
                    completionHandler(nil)
                }
            })
        })
    }
}
