//
//  ApiParser.swift
//  ApiModel
//
//  Created by Erik Rothoff Andersson on 01/06/15.
//
//

import Foundation

public protocol ApiParser {
    func parse(responseString: String, completionHandler: (AnyObject?) -> Void)
}