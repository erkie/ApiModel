import Foundation

public enum ApiRoutesAction {
    case index
    case show
    case create
    case update
    case destroy
}


open class ApiRoutes {
    open var index: String
    open var show: String
    open var create: String
    
    open var update: String {
        get {
            return show
        }
    }

    open var destroy: String {
        get {
            return show
        }
    }

    open class func resource(_ resourcePath: String) -> ApiRoutes {
        return ApiRoutes(index: resourcePath, show: resourcePath)
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
    
    open func getAction(_ resourceAction: ApiRoutesAction) -> String {
        switch resourceAction {
        case .index:
            return index
        case .create:
            return create
        case .show:
            return show
        case .update:
            return update
        case .destroy:
            return destroy
        }
    }
}
