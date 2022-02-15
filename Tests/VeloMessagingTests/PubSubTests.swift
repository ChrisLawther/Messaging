import XCTest
import SwiftZeroMQ
import SwiftProtobuf
@testable import VeloMessaging

final class PubSubTests: XCTestCase {
    var ctx: ZMQ!
    var publisher: PublisherSocket!
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
        let update = try RiderMetrics.init(serializedData: received[1])

        XCTAssertEqual(topic, "update")
        XCTAssertEqual(update.power, 243)
    }

    func testSubscriberCanBeNotifiedOfMessagesToTopic() throws {
        let message = RiderMetrics.with {
            $0.power = 243
            $0.cadence = 93
            $0.heartrate = 165
        }

        try subscriber.subscribe(to: "update")
        try publisher.publish(topic: "update", message)

        let subscriberWasNotified = expectation(description: "Subscriber should have received update")

        subscriber.on(topic: "update") { (update: RiderMetrics) in
            XCTAssertEqual(update.power, 243)
            XCTAssertEqual(update.cadence, 93)
            XCTAssertEqual(update.heartrate, 165)
            subscriberWasNotified.fulfill()
        }

        wait(for: [subscriberWasNotified], timeout: 1)
    }
}
