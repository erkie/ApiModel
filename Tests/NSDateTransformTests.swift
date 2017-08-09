//
//  NSDateTransformTests.swift
//  ApiModel
//
//  Created by Erik Rothoff Andersson on 2016-05-01.
//
//

import XCTest
import ApiModel

class NSDateTransformTests: XCTestCase {
    
    var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    let utcTimeZone = TimeZone(identifier: "Etc/UTC")!
    let yyyyMMDDDateFormatter = DateFormatter()
    
    override func setUp() {
        calendar.timeZone = utcTimeZone
        yyyyMMDDDateFormatter.timeZone = utcTimeZone
        yyyyMMDDDateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    func testISO8601WithoutTimezone() {
        let transform = DateTransform()
        let res = transform.perform("2015-12-30T12:12:33.000Z", realm: nil) as? Date
        
        var referenceDateCreator = DateComponents()
        (referenceDateCreator as NSDateComponents).timeZone = utcTimeZone
        referenceDateCreator.year = 2015
        referenceDateCreator.month = 12
        referenceDateCreator.day = 30
        referenceDateCreator.hour = 12
        referenceDateCreator.minute = 12
        referenceDateCreator.second = 33
        
        let referenceDate = calendar.date(from: referenceDateCreator)
        
        XCTAssertEqualWithAccuracy(res!.timeIntervalSinceReferenceDate, referenceDate!.timeIntervalSinceReferenceDate, accuracy: 0.001)
    }
    
    func testISO8601WithTimezone() {
        let transform = DateTransform()
        let res = transform.perform("2015-12-30T12:12:33.000-05:00", realm: nil) as? Date
        
        var referenceDateCreator = DateComponents()
        (referenceDateCreator as NSDateComponents).timeZone = utcTimeZone
        referenceDateCreator.year = 2015
        referenceDateCreator.month = 12
        referenceDateCreator.day = 30
        referenceDateCreator.hour = 12 + 5 // UTC is + 5 hours
        referenceDateCreator.minute = 12
        referenceDateCreator.second = 33
        
        let referenceDate = calendar.date(from: referenceDateCreator)
        
        XCTAssertEqualWithAccuracy(res!.timeIntervalSinceReferenceDate, referenceDate!.timeIntervalSinceReferenceDate, accuracy: 0.001)
    }
    
    func testUserDefinedDateFormat() {
        let transform = DateTransform(dateFormat: "yyyy-MM-dd")
        let res = transform.perform("2015-12-30", realm: nil) as? Date
        
        var referenceDateCreator = DateComponents()
        (referenceDateCreator as NSDateComponents).timeZone = utcTimeZone
        referenceDateCreator.year = 2015
        referenceDateCreator.month = 12
        referenceDateCreator.day = 30
        
        let referenceDate = calendar.date(from: referenceDateCreator)
        
        XCTAssertEqual(yyyyMMDDDateFormatter.string(from: res!), yyyyMMDDDateFormatter.string(from: referenceDate!))
    }
    
    
    func testInvalidDate() {
        let transform = DateTransform()
        let res = transform.perform("i am not a date", realm: nil) as? Date
        XCTAssertNil(res)
    }
}
