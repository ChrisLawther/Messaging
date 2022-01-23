import XCTest
import SwiftZeroMQ
import SwiftProtobuf
@testable import VeloMessaging

extension SwiftProtobuf.Message {
    static var identifier: Data { String(describing: Self.self).data(using: .utf8)! }
}

extension WriteableSocket {
    func send<T: SwiftProtobuf.Message>(_ msg: T) throws {
        try send([T.identifier, msg.serializedData()])
    }
}

struct SomeError: Error {}

extension ReadableSocket {
    func receive<T: SwiftProtobuf.Message>() throws -> T {
        let data = try receiveMultipartMessage()
        guard data[0] == T.identifier else {
            throw SomeError()
        }
        return try T.init(serializedData: data[1])
    }
}

final class VeloMessagingTests: XCTestCase {
    var ctx: ZMQ!
    var pusher: WriteableSocket!
    var puller: ReadableSocket!

    static let endpoint = Endpoint.inproc(name: "proto")

    override func setUpWithError() throws {
        ctx = try ZMQ.standard()
        pusher = try ctx.pushSocket()
        puller = try ctx.pullSocket()

        try pusher.connect(to: Self.endpoint)
        try puller.bind(to: Self.endpoint)
    }

    func testCanSendAClientUpdate() throws {
        let message = RiderMetrics.with {
            $0.power = 243
            $0.cadence = 93
            $0.heartrate = 165
        }

        try pusher.send(message)

        let deserialized: RiderMetrics = try puller.receive()

        XCTAssertEqual(deserialized.power, 243)
        XCTAssertEqual(deserialized.cadence, 93)
        XCTAssertEqual(deserialized.heartrate, 165)
    }
}
