import SwiftZeroMQ
import SwiftProtobuf

public extension PublisherSocket {
    /// Sends the provided message to the specified topic
    /// - Parameter topic: The topic
    /// - Parameter msg: The message to serialize and send
    func publish<T: SwiftProtobuf.Message>(topic: String, _ msg: T) throws {
        try send([topic.data(using: .utf8)!, msg.serializedData()])
    }

    /// Sends the provided message as a two-part message comprising
    /// the identifier followed by the serialized message
    /// - Parameter msg: The message to send
    func publish<T: SwiftProtobuf.Message>(_ msg: T) throws {
        try send([T.identifier, msg.serializedData()])
    }
}
