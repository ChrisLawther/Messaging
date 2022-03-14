import XCTest
import SwiftZeroMQ
import SwiftProtobuf
@testable import Messaging

final class ReadableTests: XCTestCase {
    var ctx: ZMQ!
    var readable: ReadableSocket!
    var writable: WriteableSocket!

    static let endpoint = Endpoint.inproc(name: "readable")

    override func setUpWithError() throws {
        ctx = try ZMQ.standard()
        writable = try ctx.pushSocket()
        readable = try ctx.pullSocket()

        try writable.bind(to: Self.endpoint)
        try readable.connect(to: Self.endpoint)
    }

    func testWhenExpectedMessageTypeIsReceived_DeserialisedMessageIsReceived() throws {

        let message = RiderMetrics.with {
            $0.power = 243
            $0.cadence = 93
            $0.heartrate = 165
        }

        try writable.send(message)

        _ = try readable.receive(RiderMetrics.self)
    }

    func test_WhenUnexpectedMessageTypeIsReceived_ReceiveThrows() throws {

        let message = RiderMetrics.with {
            $0.power = 243
            $0.cadence = 93
            $0.heartrate = 165
        }

        try writable.send(message)

        XCTAssertThrowsError(try readable.receive(ClientUpdate.self))
    }

    func test_WhenAHandlerIsRegisteredForAMessageType_MessageIsPassedToHandler() throws {

        let message = RiderMetrics.with {
            $0.power = 243
            $0.cadence = 93
            $0.heartrate = 165
        }

        let messageRecieved = expectation(description: "Message should have been received")

        readable.on(RiderMetrics.self) { msg in
            messageRecieved.fulfill()
        }

        try writable.send(message)

        wait(for: [messageRecieved], timeout: 1)
    }

    func test_WhenAHandlerIsRegisteredForAMessageTypeWhichCantBeDeserialised_HandlerIsNotCalled() throws {

        let message = RiderMetrics.with {
            $0.power = 243
            $0.cadence = 93
            $0.heartrate = 165
        }

        // Currently, we don't have a way to force synchronous message delivery, so resort
        // to delaying tactics.
        let messageDelivery = expectation(description: "Message delivery")

        readable.on(RiderMetrics.self) { msg in
            XCTFail("Should NOT have been called")
        }

        // Manually send an unexpected identifier/payload-type combination
        try writable.send([
            "unexpected".data(using: .utf8)!,
            message.serializedData()
        ])

        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 0.5, {
            messageDelivery.fulfill()
        })

        wait(for: [messageDelivery], timeout: 1)
    }
}
