import Foundation

@objc
public class ApiResource {
    public var index: String
    public var show: String
    public var create: String

    public var update: String {
        get {
            return show
        }
    }

    public class func resource(resourcePath: String) -> ApiResource {
        return ApiResource(index: resourcePath, show: resourcePath)
    }

    public init(index: String, show: String, create: String) {
        self.index = index
        self.show = show
        self.create = create
    }

    public convenience init(index: String, show: String) {
        self.init(index: index, show: show, create: index)
    }

    public convenience init() {
        self.init(index: "NO RESOURCE DEFINED", show: "NO RESOURCE DEFINED", create: "NO RESOURCE DEFINED")
    }
}
