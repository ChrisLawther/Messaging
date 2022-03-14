import Foundation
import SwiftProtobuf
import SwiftZeroMQ

/// Thrown when/if the identifier of a received message does not match the expected identifier
public struct ProtobufDecodingError: Error, LocalizedError {
    let expectedIdentifier: Data
    let actualIdentifier: Data
}
