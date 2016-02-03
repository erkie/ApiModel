public typealias ApiId = String

public class ApiIdTransform: StringTransform {
}

// Since we have decided to store all IDs as strings we need to sometimes convert API responses to IDs.
public func convertToApiId(anything: AnyObject?) -> ApiId? {
    if let intId = anything as? Int {
        return String(intId)
    } else if let stringId = anything as? String {
        return stringId
    } else {
        return nil
    }
}