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

	public func perform(value: AnyObject?) -> AnyObject {
		if let doubleValue = value as? Double {
			return doubleValue
		} else if let stringValue = value as? String {
			return (stringValue as NSString).doubleValue
		} else {
			return 0
		}
	}
}