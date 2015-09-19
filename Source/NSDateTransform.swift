import Foundation

public class NSDateTransform: Transform {
    public init() {}

    public func perform(value: AnyObject?) -> AnyObject? {
        if let dateValue = value as? NSDate {
            return dateValue
        }

        // Rails dates with time and zone
        if let stringValue = value as? String {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            if let date = dateFormatter.dateFromString("\(stringValue)") {
                return toLocalTimezone(date)
            }

            // Standard short dates
            let simpleDateFormatter = NSDateFormatter()
            simpleDateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = simpleDateFormatter.dateFromString("\(stringValue)") {
                return toLocalTimezone(date)
            }
        }

        return nil
    }

    func toLocalTimezone(date: NSDate) -> NSDate {
        let seconds = NSTimeInterval(NSTimeZone.localTimeZone().secondsFromGMTForDate(date))
        return NSDate(timeInterval: seconds, sinceDate: date)
    }
}
