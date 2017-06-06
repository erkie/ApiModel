//
//  ArrayTransformTests.swift
//  ApiModel
//
//  Created by Erik Rothoff Andersson on 2016-20-01.
//
//

import XCTest
import ApiModel
import RealmSwift

class ArrayTransformTests: XCTestCase {
    
    var realm: Realm!
    var postsTransform: ArrayTransform<Post>!
    
    override func setUp() {
        try! realm = Realm()
        postsTransform = ArrayTransform<Post>()
    }
    
    override func tearDown() {
        if let fileURL = realm.configuration.fileURL {
            try! FileManager.default.removeItem(at: fileURL)
        }
    }
    
    func testACoupleOfConversions() {
        let response = [
            [
                "id": 1,
                "title": "Taking over the world"
            ],
            
            [
                "id": 2,
                "title": "Restoring peace"
            ]
        ]
        
        let posts = postsTransform.perform(response, realm: nil) as? [Post]
        
        XCTAssertEqual(posts?[0].title, "Taking over the world")
        XCTAssertEqual(posts?[0].id, "1")
        
        XCTAssertEqual(posts?[1].title, "Restoring peace")
        XCTAssertEqual(posts?[1].id, "2")
    }
    
    func testWithOneBadResponse() {
        let response = [
            [
                "id": 1,
                "title": "Taking over the world"
            ],
            
            "This api sucks"
        ] as [Any]
        
        let posts = postsTransform.perform(response, realm: nil) as? [Post]
        
        XCTAssertEqual(posts?[0].title, "Taking over the world")
        XCTAssertEqual(posts?[0].id, "1")
        XCTAssertEqual(posts!.count, 1)
    }
    
    func testWithPersistedObjects() {
        // Create a couple of persisted objects
        let persistedPost0 = Post()
        persistedPost0.id = "1337"
        persistedPost0.title = "Hello world"
        
        let persistedPost1 = Post()
        persistedPost1.id = "1338"
        persistedPost1.title = "Bye world"
        
        try! realm.write {
            self.realm.add(persistedPost0, update: true)
            self.realm.add(persistedPost1, update: true)
        }
        
        let response = [
            [
                "id": "1337",
                "title": "World hello"
            ],
            
            [
                "id": "1338",
                "title": "World bye"
            ]
        ]
        
        try! realm.write {
            let posts = postsTransform.perform(response, realm: realm) as! [Post]
            
            XCTAssertEqual(posts[0].id, "1337")
            XCTAssertEqual(posts[0].title, "World hello")
            XCTAssertEqual(persistedPost0.id, "1337")
            XCTAssertEqual(persistedPost0.title, "World hello")
            
            XCTAssertEqual(posts[1].id, "1338")
            XCTAssertEqual(posts[1].title, "World bye")
            XCTAssertEqual(persistedPost1.id, "1338")
            XCTAssertEqual(persistedPost1.title, "World bye")
        }
    }
    
    func testWithPersistedObjectsButDuplicatesInArrayResponse() {
        // If an API returns the same object ID twice in an array, it could lead to weird realm crashes
        // Create a couple of persisted objects
        let persistedPost0 = Post()
        persistedPost0.id = "1337"
        persistedPost0.title = "Hello world"
        
        try! realm.write {
            self.realm.add(persistedPost0, update: true)
        }
        
        let response = [
            [
                "id": "1337",
                "title": "World hello"
            ],
            
            [
                "id": "1337",
                "title": "World hello hello"
            ]
        ]
        
        try! realm.write {
            let posts = postsTransform.perform(response, realm: realm) as! [Post]
            
            XCTAssertEqual(posts[0].id, "1337")
            XCTAssertEqual(posts[0].title, "World hello hello")
            XCTAssertEqual(posts[1].id, "1337")
            XCTAssertEqual(posts[1].title, "World hello hello")
            XCTAssertEqual(persistedPost0.id, "1337")
            XCTAssertEqual(persistedPost0.title, "World hello hello")
        }
    }
    
    func testWithNestedModelsAndDuplicateIDs() {
        // If an API returns the same object ID twice in an array, it could lead to weird realm crashes
        // Create a couple of persisted objects
        let feed = Feed()
        feed.id = "1"
        feed.title = "Hello world"
        
        try! realm.write {
            self.realm.add(feed, update: true)
        }
        
        let response = [
            "id": "1",
            "title": "Hello world",
            "posts": [
                [
                    "id": "1337",
                    "title": "World hello"
                ],
                
                [
                    "id": "1337",
                    "title": "World hello hello"
                ]
            ]
        ] as [String : Any]
        
        let feedTransform = ModelTransform<Feed>()
    
        try! realm.write {
            let feedFromResponse = feedTransform.perform(response, realm: feed.realm) as? Feed
            
            XCTAssertEqual(feedFromResponse?.posts[0].id, "1337")
            XCTAssertEqual(feedFromResponse?.posts[0].title, "World hello hello")
        }
    }
}
