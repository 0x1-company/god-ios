import Foundation
import UserNotifications
import FirebaseMessaging

public struct FirebaseMessagingClient {
  public var delegate: @Sendable () -> AsyncStream<Void>
  public var setAPNSToken: @Sendable (Data) -> Void
  public var token: @Sendable () async throws -> String
  public var appDidReceiveMessage: @Sendable (UNNotificationRequest) -> MessagingMessageInfo
}
