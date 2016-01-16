import Foundation

public class NSDateTransform: Transform {
    var dateFormatters: [NSDateFormatter] = []
    
    public init() {
        // ISO 8601 dates with time and zone
        let iso8601Formatter = NSDateFormatter()
        iso8601Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        dateFormatters.append(iso8601Formatter)
    }
    
    public init(dateFormat: String) {
        let userDefinedDateFormatter = NSDateFormatter()
        userDefinedDateFormatter.dateFormat = dateFormat
        
        dateFormatters.insert(userDefinedDateFormatter, atIndex: 0)
    }
    
    public func perform(value: AnyObject?) -> AnyObject? {
        if let dateValue = value as? NSDate {
            return dateValue
        }

        if let stringValue = value as? String {
            for formatter in dateFormatters {
                if let date = formatter.dateFromString(stringValue) {
                    return date
                }
            }
        }

        return nil
    }
}
