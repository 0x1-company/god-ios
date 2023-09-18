import Dependencies
import UserNotifications
import XCTestDynamicOverlay

extension DependencyValues {
  public var userNotifications: UserNotificationClient {
    get { self[UserNotificationClient.self] }
    set { self[UserNotificationClient.self] = newValue }
  }
}

extension UserNotificationClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self(
    notificationSettings: unimplemented("\(Self.self).notificationSettings", placeholder: UNAuthorizationStatus.notDetermined),
    requestAuthorization: unimplemented("\(Self.self).requestAuthorization")
  )
}

extension UserNotificationClient {
  public static let noop = Self(
    notificationSettings: { UNAuthorizationStatus.notDetermined },
    requestAuthorization: { _ in false }
  )
}
