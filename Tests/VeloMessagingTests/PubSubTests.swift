import XCTest
import SwiftZeroMQ
import SwiftProtobuf
@testable import VeloMessaging

extension WriteableSocket {
    func publish<T: SwiftProtobuf.Message>(topic: String, _ msg: T) throws {
        try send([topic.data(using: .utf8)!, T.identifier, msg.serializedData()])
    }
}

final class PubSubTests: XCTestCase {
    var ctx: ZMQ!
    var publisher: WriteableSocket!
    var subscriber: SubscriberSocket!

    static let endpoint = Endpoint.inproc(name: "proto")

    override func setUpWithError() throws {
        ctx = try ZMQ.standard()
        publisher = try ctx.publisherSocket()
        subscriber = try ctx.subscriberSocket()

        try subscriber.connect(to: Self.endpoint)
        try publisher.bind(to: Self.endpoint)
    }

    func testSubscriberCanReceiveMessagesToTopic() throws {
        let message = RiderMetrics.with {
            $0.power = 243
            $0.cadence = 93
            $0.heartrate = 165
        }

        try subscriber.subscribe(to: "update")

        try publisher.publish(topic: "update", message)

        let received = try subscriber.receiveMultipartMessage()

        let topic = String(data: received[0], encoding: .utf8)
        let identifier = String(data: received[1], encoding: .utf8)
        let update = try RiderMetrics.init(serializedData: received[2])

        XCTAssertEqual(topic, "update")
        XCTAssertEqual(identifier, "RiderMetrics")
        XCTAssertEqual(update.power, 243)
    }
}
