import Foundation

public class ApiCall {
    public var resource: String?
    public var namespace: String?

    public init() {}

    public init(resource: String) {
        self.resource = resource
    }

    public init(namespace: String) {
        self.namespace = namespace
    }

    public init(namespace: String, resource: String) {
        self.namespace = namespace
        self.resource = resource
    }

    public func provideDefaults<T:ApiTransformable>(model: T.Type) {
        if namespace == nil {
            namespace = model.apiNamespace()
        }

        if resource == nil {
            resource = model.apiRoutes().index
        }
    }
}
