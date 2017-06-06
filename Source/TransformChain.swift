import Foundation
import RealmSwift

open class TransformChain: Transform {
    open var transforms: [Transform] = []

    public init(transforms: Transform...) {
        self.transforms = transforms
    }

    open func perform(_ value: Any?, realm: Realm?) -> Any? {
        return transforms.reduce(value!) { $1.perform($0, realm: realm) }
    }
}
