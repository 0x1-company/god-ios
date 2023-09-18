import ComposableArchitecture
import UserNotifications

public struct UserNotificationClient {
  public var notificationSettings: @Sendable () async -> UNAuthorizationStatus
  public var requestAuthorization: @Sendable (UNAuthorizationOptions) async throws -> Bool
}
