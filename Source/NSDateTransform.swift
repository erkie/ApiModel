import Foundation
import RealmSwift

let standardTimeZone = TimeZone(secondsFromGMT: 0)

open class DateTransform: Transform {
    var dateFormatters: [DateFormatter] = []
    
    public init() {
        // ISO 8601 dates with time and zone
        let iso8601Formatter = DateFormatter()
        iso8601Formatter.timeZone = standardTimeZone
        iso8601Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        dateFormatters.append(iso8601Formatter)
    }
    
    public init(dateFormat: String) {
        let userDefinedDateFormatter = DateFormatter()
        userDefinedDateFormatter.timeZone = standardTimeZone
        userDefinedDateFormatter.dateFormat = dateFormat
        
        dateFormatters.insert(userDefinedDateFormatter, at: 0)
    }
    
    open func perform(_ value: Any?, realm: Realm?) -> Any? {
        if let dateValue = value as? Date {
            return dateValue
        }

        if let stringValue = value as? String {
            for formatter in dateFormatters {
                if let date = formatter.date(from: stringValue) {
                    return date
                }
            }
        }

        return nil
    }
}
