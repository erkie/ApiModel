//
//  RLMArray+Array.swift
//  APIModel
//
//  Created by Erik Rothoff Andersson on 03/05/15.
//
//

import Foundation
import Realm

public class ToArray<T> {
    var realmArray: RLMArray
    public init(realmArray: RLMArray) {
        self.realmArray = realmArray
    }
    
    public func get() -> [T] {
        var retArray: [T] = []
        for obj in realmArray {
            retArray.append(obj as! T)
        }
        return retArray
    }
}