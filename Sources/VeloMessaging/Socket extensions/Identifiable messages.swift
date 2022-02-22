import Foundation
import SwiftProtobuf
import SwiftZeroMQ

/// Thrown when/if the identifiet of a received message does not match the expected identifier
public struct ProtobufDecodingError: Error, LocalizedError {
    let expectedIdentifier: Data
    let actualIdentifier: Data
}

// MARK: - Identifying messages by their type

public extension SwiftProtobuf.Message {
    /// String representation of the message type
    static var identifier: Data {
        String(describing: Self.self).data(using: .utf8)!
    }
}

// MARK: - Sending typed, identified messages

public extension WriteableSocket {
    /// Sends the provided message as a two-part message comprising the identifier followed by the serialized message
    /// - Parameter msg: The message to send
    func send<T: SwiftProtobuf.Message>(_ msg: T) throws {
        try send([T.identifier, msg.serializedData()])
    }
}

public extension PublisherSocket {
    /// Sends the provided message to the specified topic
    /// - Parameter topic: The topic
    /// - Parameter msg: The message to serialize and send
    func publish<T: SwiftProtobuf.Message>(topic: String, _ msg: T) throws {
        try send([topic.data(using: .utf8)!, msg.serializedData()])
    }
}

// MARK: - Receiving typed, identified messages

public extension SubscriberSocket {
    /// Register a handler for a specific protobuf message type on a topic identified by the message type
    /// - Parameter handler: Closure to handle any received messages
    func subscribe<T: SwiftProtobuf.Message>(handler: @escaping (T) -> Void) throws -> Void {
        try subscribe(to: T.identifier)
        on(T.identifier) { data in
            guard let message = try? T.init(serializedData: data[0]) else {
                return  // Not decodable to the expected type
            }
            handler(message)
        }
    }
}

public extension ReadableSocket {
    /// Receive a typed, identified message
    /// - Returns: A protobuf message
    /// - Throws: When the payload could not be decoded to the expected type
    func receive<T: SwiftProtobuf.Message>() throws -> T {
        let data = try receiveMultipartMessage()
        guard data[0] == T.identifier else {
            throw ProtobufDecodingError(expectedIdentifier: T.identifier,
                                        actualIdentifier: data[0])
        }
        return try T.init(serializedData: data[1])
    }
}

public extension ReadableSocket {
    /// Register a handler for a specific protobuf message type
    /// - Parameter type: The message type of interest
    /// - Parameter handler: Closure to handle any received messages
    func on<T: SwiftProtobuf.Message>(_ type: T.Type = T.self, handler: @escaping (T) -> Void) -> Void {
        on(type.identifier) { data in
            guard let message = try? T.init(serializedData: data[0]) else {
                return
            }
            handler(message)
        }
    }
}

public extension SubscriberSocket {
    /// Register a handler for a specific protobuf message type on a specific topic
    /// - Parameter topic: The topic to monitor
    /// - Parameter handler: Closure to handle any received messages
    func on<T: SwiftProtobuf.Message>(topic: String, handler: @escaping (T) -> Void) -> Void {
        let topic = topic.data(using: .utf8)!

        on(topic) { data in
            guard let message = try? T.init(serializedData: data[0]) else {
                return  // Not decodable to the expected type
            }
            handler(message)
        }
    }
}
