//
//  BuilderTests.swift
//  APIModel
//
//  Created by Erik Rothoff Andersson on 2016-05-04.
//
//

import XCTest
import ApiModel
import OHHTTPStubs
import SwiftyJSON

class BuilderTests: XCTestCase {
    
    class IdRenameBuilder: Builder {
        override func build(data: JSON) -> JSON {
            return JSON(object: [
                "id": data["_ID"].string,
                "title": data["object.member.TITLE"].string
            ])
        }
    }
    
    let wonkyApiResponse: [String:AnyObject?] = [
        "_ID": "1",
        "object.member.TITLE": "hello world"
    ]
    
    let wonkyStringApiResponse = "{\"_ID\": \"1\", \"object.member.TITLE\": \"hello world\"}"
    
    override func setUp() {
        super.setUp()
        
        stub({_ in true}) { request in
            let data = self.wonkyStringApiResponse.dataUsingEncoding(NSUTF8StringEncoding)!
            return OHHTTPStubsResponse(data: data, statusCode: 200, headers: [:])
        }
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        
        super.tearDown()
    }

    func testSimpleCustomBuilder() {
        let idBuilder = IdRenameBuilder()
        
        let post = idBuilder.build(JSON(object: wonkyApiResponse))
            
        XCTAssertEqual(post["id"].string, "1")
        XCTAssertEqual(post["title"].string, "hello world")
    }
    
    func testIntegrationSimpleCustomBuilder() {
        let readyExpectation = self.expectationWithDescription("ready")
        
        Api<Post>.get("/post-id", parameters: [:]) { response in
            let post = response.object
            
            XCTAssertNotNil(post)
            
            XCTAssertEqual(post?.id, "1")
            XCTAssertEqual(post?.title, "hello world")
            
            readyExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1000) { err in
        }
    }

}
