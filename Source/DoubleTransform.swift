//
//  DoubleTransform.swift
//  APIModel
//
//  Created by Damien Timewell on 04/05/2015.
//
//

import Foundation

public class DoubleTransform: Transform {
	public init() {}

	public func perform(value: AnyObject) -> AnyObject {
		if value is Double {
			return value
		} else if value is String {
			return (value as! NSString).doubleValue
		} else {
			return value
		}
	}
}