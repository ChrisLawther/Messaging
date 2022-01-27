import SwiftProtobuf

extension SwiftProtobuf.Message {
    static var identifier: Data { String(describing: Self.self).data(using: .utf8)! }
}

extension WriteableSocket {
    func send<T: SwiftProtobuf.Message>(_ msg: T) throws {
        try send([T.identifier, msg.serializedData()])
    }
}
