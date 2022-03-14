import SwiftZeroMQ
import SwiftProtobuf

// MARK: - Immediate reception of a specific type

public extension ReadableSocket {
    /// Receive a typed, identified message
    ///
    /// Note: This is rarely useful. Scenarios in which the type of the
    /// next message to be received are rare.
    /// - Returns: A protobuf message
    /// - Throws: When the payload could not be decoded to the expected type
    func receive<T: SwiftProtobuf.Message>(_ type: T.Type = T.self) throws -> T {
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
