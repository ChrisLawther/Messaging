import Foundation
import SwiftProtobuf
import SwiftZeroMQ

public extension SwiftProtobuf.Message {
    static var identifier: Data { String(describing: Self.self).data(using: .utf8)! }
}

public extension WriteableSocket {
    func send<T: SwiftProtobuf.Message>(_ msg: T) throws {
        try send([T.identifier, msg.serializedData()])
    }
}

public struct ProtobufDecodingError: Error, LocalizedError {
    let expectedIdentifier: Data
    let actualIdentifier: Data
}

public extension ReadableSocket {
    func receive<T: SwiftProtobuf.Message>() throws -> T {
        let data = try receiveMultipartMessage()
        guard data[0] == T.identifier else {
            throw ProtobufDecodingError(expectedIdentifier: T.identifier,
                                        actualIdentifier: data[0])
        }
        return try T.init(serializedData: data[1])
    }
}
