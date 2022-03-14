import SwiftZeroMQ
import SwiftProtobuf

public extension WriteableSocket {
    /// Sends the provided message as a two-part message comprising
    /// the identifier followed by the serialized message
    /// - Parameter msg: The message to send
    func send<T: SwiftProtobuf.Message>(_ msg: T) throws {
        try send([T.identifier, msg.serializedData()])
    }
}
