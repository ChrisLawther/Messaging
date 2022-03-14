# SwiftZeroMQ+Protobuf

Bringing together both Apple's [Swift Protobuf][1] package and [SwiftZeroMQ][2], this package does two key things:

1. Extend `SwiftProtobuf.Message` to have an `.identifier` property. When sending, this is used to generate a two-part message comprising the identifier and the serialised body. The identifier serves two purposes. It can be used in a pub/sub scenario to selectively receive messages. It also informs the receiver what type to attempt to deserialise to.
2. Extends various `SwiftZeroMQ` socket types with conveniences for the sending and reception of those self-identifying message types.

[1]: https://github.com/apple/swift-protobuf.git
[2]: https://github.com/ChrisLawther/SwiftZeroMQ

## Usage examples

To immediately receive a message of a specific type:

    // The following calls are equivalent
    let receivedMessage: SomeMessage = try readableSocket.receive()
    let receivedMessage = try readableSocket.receive(SomeMessage.self)
    
To be notified whenever a message of a specific type is received:

    readableSocket.on(SomeMessage.self) { msg in
        // Handle msg
    }

To subscribe to messages of type `SomeMessage` on a subscriber socket:

    subscriberSocket.subscribe { (msg: SomeMessage) in
        // Handle msg
    }

To publish a message of type `SomeMessage`:

    let msg = SomeMessage.with {
        // Property assignment here
        $0.value = 123
    }
    
    // Sends a two-part message:
    // [0] - "SomeMessage" .utf8 representation
    // [1] - serialised form of `msg`
    publisherSocket.publish(msg)

To subscribe to a message of type `SomeMessage` (the publisher will send us only messages of types we've expressed an interest in) and handle reception of those messages:

    subscriberSocket.subscribe{ (msg: SomeMessage) in
         // Handle msg
    }
    // OR
    subsciberSocket.subscribe(to: SomeMessage.self) { msg in
        // Handle msg
    }
