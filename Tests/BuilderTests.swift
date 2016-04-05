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

class BuilderTests: XCTestCase {
    
    class IdRenameBuilder: Builder {
        override func build(data: [String:AnyObject?]) -> AnyObject? {
            return buildObject([
                "id": data["_ID"] ?? nil,
                "title": data["object.member.TITLE"] ?? nil
            ])
        }
        
        override func buildObject(data: [String : AnyObject?]) -> AnyObject? {
            let post = Post()
            for (key, value) in data {
                post[key] = value
            }
            return post
        }
    }
    
    let wonkyApiResponse: [String:AnyObject?] = [
        "_ID": "1",
        "object.member.TITLE": "hello world"
    ]
    
    let wonkyStringApiResponse = "{\"_ID\": \"1\", \"object.member.TITLE\": \"hello world\"}"
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSimpleCustomBuilder() {
        let idBuilder = IdRenameBuilder()
        
        let post = idBuilder.build(wonkyApiResponse) as! Post
            
        XCTAssertEqual(post.id, "1")
        XCTAssertEqual(post.title, "hello world")
    }
    
    func testIntegrationSimpleCustomBuilder() {
        let readyExpectation = self.expectationWithDescription("ready")
        
        stub({_ in true}) { request in
            let data = self.wonkyStringApiResponse.dataUsingEncoding(NSUTF8StringEncoding)!
            return OHHTTPStubsResponse(data: data, statusCode: 200, headers: [:])
        }
        
        Api<Post>.get("/post-id", parameters: [:]) { response in
            let post = response.object!
            
            XCTAssertEqual(post.id, "1")
            XCTAssertEqual(post.title, "hello world")
            
            readyExpectation.fulfill()
            OHHTTPStubs.removeAllStubs()
        }
        
        waitForExpectationsWithTimeout(1000) { err in
        }
    }

}
