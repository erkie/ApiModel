//
//  ApiResponseTests.swift
//  ApiModel
//
//  Created by Craig Heneveld on 1/14/16.
//
//

import XCTest
import ApiModel
import Alamofire
import OHHTTPStubs
import RealmSwift

class ApiManagerResponseTests: XCTestCase {
    var timeout: TimeInterval = 10
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
    
    func testNotFoundResponse() {
        var theResponse: ApiModelResponse<Post>?
        let readyExpectation = self.expectation(description: "ready")
        
        stub(condition: {_ in true}) { request in
            OHHTTPStubsResponse(
                data:"File not found".data(using: String.Encoding.utf8)!,
                statusCode: 404,
                headers: nil
            )
        }
        
        Api<Post>.get("/v1/posts.json") { response in
            
            XCTAssertEqual(response.rawResponse!.status!, 404, "A response should have a status of 404")
            XCTAssertEqual(String(describing: response.rawResponse!.error!), "invalidRequest(404)")
            XCTAssertTrue(response.rawResponse!.isInvalid, "A response status of 404 should be invalid")
            
            theResponse = response
            
            readyExpectation.fulfill()
            OHHTTPStubs.removeAllStubs()
        }
        
        
        waitForExpectations(timeout: self.timeout) { err in
            // By the time we reach this code, the while loop has exited
            // so the response has arrived or the test has timed out
            XCTAssertNotNil(theResponse, "Received data should not be nil")
        }
    }
    
    func testServerErrorResponse() {
        var theResponse: ApiModelResponse<Post>?
        let readyExpectation = self.expectation(description: "ready")
        
        stub(condition: {_ in true}) { request in
            OHHTTPStubsResponse(data
                :"Something went wrong!".data(using: String.Encoding.utf8)!,
                statusCode: 500,
                headers: nil
            )
        }

        Api<Post>.get("/v1/posts.json") { response in
            
            XCTAssertEqual(response.rawResponse!.status!, 500, "A response should have a status of 500")
            XCTAssertEqual(String(describing: response.rawResponse!.error!), "badRequest(500)")
//            XCTAssertTrue(response.rawResponse!.isInvalid, "A response status of 500 should be invalid")
            
            theResponse = response
            
            readyExpectation.fulfill()
            OHHTTPStubs.removeAllStubs()
        }
        
        waitForExpectations(timeout: self.timeout) { err in
            // By the time we reach this code, the while loop has exited
            // so the response has arrived or the test has timed out
            XCTAssertNotNil(theResponse, "Received data should not be nil")
        }
    }
    
    func testSessionConfig() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 1 // seconds
        configuration.timeoutIntervalForResource = 1
        
        ApiSingleton.setInstance(ApiManager(config: ApiConfig(host: self.host, urlSessionConfig:configuration)))

        let readyExpectation = expectation(description: "ready")
        
        stub(condition: { _ in true }) { request in
            OHHTTPStubsResponse(
                data: "Something went wrong!".data(using: String.Encoding.utf8)!,
                statusCode: 500,
                headers: nil
            ).requestTime(2.0, responseTime: 2.0)
        }
        
        Api<Post>.get("/v1/posts.json") { response in
            
            // -1001 indicates a timeout occured which is what's expected
            XCTAssertNil(response.rawResponse?.status, "We currently can't test for raw alamofire response codes so just checking if status is nil. Which failed.")
            
            readyExpectation.fulfill()
            OHHTTPStubs.removeAllStubs()
        }
        
        waitForExpectations(timeout: self.timeout) { err in
            // By the time we reach this code, the while loop has exited
            // so the response has arrived or the test has timed out
            XCTAssertNil(err, "Timeout occured")
        }
    }
}
