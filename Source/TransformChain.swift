import Foundation
import RealmSwift

public class TransformChain: Transform {
    public var transforms: [Transform] = []

    public init(transforms: Transform...) {
        self.transforms = transforms
    }

    public func perform(value: AnyObject?, realm: Realm?) -> AnyObject? {
        return transforms.reduce(value!) { $1.perform($0, realm: realm) }
    }
}
