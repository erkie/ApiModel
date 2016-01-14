//
//  ApiFormTests.swift
//  APIModel
//
//  Created by Craig Heneveld on 1/14/16.
//
//

import XCTest
import ApiModel
import Alamofire
import OHHTTPStubs
import RealmSwift

class ApiFormTests: XCTestCase {
    var timeout: NSTimeInterval = 10
    var testRealm: Realm!
    var host = "http://you-dont-party.com"
    
    override func setUp() {
        
        super.setUp()
        
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        
        testRealm = try! Realm()
        
        ApiSingleton.setInstance(ApiManager(config: ApiConfig(host: self.host)))
    }
    
    override func tearDown() {
        
        super.tearDown()
        
        try! testRealm.write {
            self.testRealm.deleteAll()
        }
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFindArrayWithServerFailure() {
        
        var theResponse: [Post]?
        let readyExpectation = self.expectationWithDescription("ready")
        
        stub({_ in true}) { request in
            let stubPath = OHPathForFile("posts.json", self.dynamicType)
            return fixture(stubPath!, headers: ["Content-Type":"application/json"])
        }
        
        Api<Post>.findArray { response in
            theResponse = response
            
            XCTAssertEqual(response.count, 2)
            XCTAssertEqual(response.first!.id, "1")
            XCTAssertEqual(response.last!.id, "2")
            
            readyExpectation.fulfill()
            OHHTTPStubs.removeAllStubs()
        }
        
        
        self.waitForExpectationsWithTimeout(self.timeout) { err in
            // By the time we reach this code, the while loop has exited
            // so the response has arrived or the test has timed out
            XCTAssertNotNil(theResponse, "Received data should not be nil")
        }
    }
}
