import Foundation
import SwiftProtobuf

public extension SwiftProtobuf.Message {
    /// String representation of the message type
    static var identifier: Data {
        String(describing: Self.self).data(using: .utf8)!
    }
}
