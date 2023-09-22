import Foundation

public struct FirebaseMessagingClient {
  public var delegate: @Sendable () -> AsyncStream<Void>
  public var setAPNSToken: @Sendable (Data) -> Void
}
