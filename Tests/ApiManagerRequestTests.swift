//
//  ApiManagerRequestTests.swift
//  APIModel
//
//  Created by Erik Rothoff Andersson on 2016-01-01.
//
//

import XCTest
import ApiModel
import Alamofire

class ApiManagerRequestTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEmptyRootNamespace() {
        // given
        let config = ApiConfig()
        let apiManager = ApiManager(config: config)
        
        let apiRequest = ApiRequest(config: config, method: .get, path: "/example.json")
        
        let response = ApiResponse(request: apiRequest)
        let parsedResponse = [
            "post": [
                "id": "1"
            ]
        ]
        
        // when
        let (finalResponse, _) = apiManager.handleResponse(
            response,
            parsedResponse: parsedResponse,
            apiConfig: config
        )
        
        // then
        let responseObject = finalResponse!.parsedResponse as! [String:Any]
        XCTAssertEqual((responseObject["post"] as! [String:Any])["id"]! as? String, "1")
    }

    func testSimpleRootNamespace() {
        // given
        let config = ApiConfig()
        config.rootNamespace = "data.post"
        
        let apiManager = ApiManager(config: config)
        
        let apiRequest = ApiRequest(config: config, method: .get, path: "/example.json")
        
        let response = ApiResponse(request: apiRequest)
        let parsedResponse = [
            "data": [
                "post": [
                    "id": "1"
                ]
            ]
        ]
    
        // when
        let (finalResponse, _) = apiManager.handleResponse(
            response,
            parsedResponse: parsedResponse,
            apiConfig: config
        )
        
        // then
        let responseObject = finalResponse!.parsedResponse as! [String:AnyObject]
        XCTAssertEqual(responseObject["id"] as? String, "1")
    }

}
