//
//  ModelTransformTests.swift
//  APIModel
//
//  Created by Erik Rothoff Andersson on 2016-20-01.
//
//

import XCTest
import ApiModel
import RealmSwift

class ModelTransformTests: XCTestCase {
    
    var realm: Realm!
    var postTransform: ModelTransform<Post>!
    
    override func setUp() {
        try! realm = Realm()
        postTransform = ModelTransform<Post>()
    }
    
    override func tearDown() {
        if let fileURL = realm.configuration.fileURL {
            try! FileManager.default.removeItem(at: fileURL)
        }
    }
    
    func testSimpleConversion() {
        let response = [
            "id": 1,
            "title": "Taking over the world"
        ] as [String : Any]
        
        let post = postTransform.perform(response, realm: nil) as? Post
        
        XCTAssertEqual(post?.title, "Taking over the world")
        XCTAssertEqual(post?.id, "1")
    }

    func testConversionIntoPersistedObject() {
        // Create a persisted object
        let persistedPost = Post()
        persistedPost.id = "1337"
        persistedPost.title = "Hello world"
        
        try! realm.write {
            self.realm.add(persistedPost, update: true)
        }
        
        let response = [
            "id": "1337",
            "title": "Hello world, revision II"
        ]
        
        try! realm.write {
            let otherPost = postTransform.perform(response, realm: realm) as! Post
            
            XCTAssertEqual(otherPost.id, "1337")
            XCTAssertEqual(otherPost.title, "Hello world, revision II")
            
            XCTAssertEqual(persistedPost.title, "Hello world, revision II")
        }
    }
}
