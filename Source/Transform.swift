//
//  JSONTransforms.swift
//  APIModel
//
//  Copyright (c) 2015 Rootof Creations HB. All rights reserved.
//

import Foundation

public protocol Transform {
    func perform(value: AnyObject?) -> AnyObject
}
