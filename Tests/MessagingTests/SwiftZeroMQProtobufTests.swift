import XCTest
import SwiftZeroMQ
import SwiftProtobuf
@testable import Messaging

struct SomeError: Error {}

final class SwiftZeroMQProtobufTests: XCTestCase {
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
