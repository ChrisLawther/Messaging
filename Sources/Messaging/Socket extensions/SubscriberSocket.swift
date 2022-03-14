import SwiftZeroMQ
import SwiftProtobuf

public extension SubscriberSocket {
    /// Register a handler for a specific protobuf message type on a
    /// topic identified by the message type
    /// - Parameter handler: Closure to handle any received messages
    func subscribe<T: SwiftProtobuf.Message>(to type: T.Type = T.self, handler: @escaping (T) -> Void) throws -> Void {
        try subscribe(to: T.identifier)
        on(T.identifier) { data in
            guard let message = try? T.init(serializedData: data[0]) else {
                return  // Not decodable to the expected type
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
