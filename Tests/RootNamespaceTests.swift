//
//  RootNamespaceTests.swift
//  ApiModelTests
//
//  Created by Erik Rothoff Andersson on 2015-13-08.
//
//

import UIKit
import XCTest

class RootNamespaceTests: XCTestCase {
    let nestedObject = [
        "foo": [
            "bar": [
                "baz": [
                    "bam": 42
                ]
            ]
        ]
    ]
    
    let notNested = ["foo": 43]
    let singleNesting = ["foo": ["bar": 44]]
    
    let nestedButNotDictionary = [
        "foo": [
            "bar": [1, 2, 3]
        ]
    ]
    
    func testPathFormat() {
        XCTAssertNil(fetchPathFromDictionary("", nestedObject))
        XCTAssertNil(fetchPathFromDictionary(".....................", nestedObject))
    }
    
    func testThatItCanFetchSingleKeys() {
        XCTAssert((fetchPathFromDictionary("foo", notNested) as? Int) == 43, "Should be able to fetch single keys")
        XCTAssertNil(fetchPathFromDictionary("not_exists", notNested), "Should not crash if it doesn't exist")
        XCTAssertNil(fetchPathFromDictionary("not_exists.foo.bam", notNested), "Should not crash if it doesn't exist nested")
    }
    
    func testThatItCanFetchNestingKeys() {
        XCTAssert((fetchPathFromDictionary("foo.bar.baz.bam", nestedObject) as? Int) == 42, "Should be able to fetch single keys")
        XCTAssertNil(fetchPathFromDictionary("foo.bar.BAM", nestedObject), "Should be able to handle non-existing keys")
    }
    
    func testThatItHandlesWrongTypes() {
        XCTAssertNil(fetchPathFromDictionary("foo.bar.bam", nestedButNotDictionary), "Should handle bad keys")
    }
    
    func testThatItCanFetchSingleNesting() {
        if let nested = fetchPathFromDictionary("foo", singleNesting) as? [String:Int] {
            XCTAssert(nested == ["bar": 44], "Can fetch nested objects")
        } else {
            XCTAssert(false, "Can fetch nested objects")
        }
        
        XCTAssert((fetchPathFromDictionary("foo.bar", singleNesting) as? Int) == 44, "Can fetch singly nested objects")
    }
}
