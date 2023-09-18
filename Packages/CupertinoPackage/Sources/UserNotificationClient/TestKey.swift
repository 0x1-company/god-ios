import Dependencies
import UserNotifications
import XCTestDynamicOverlay

public extension DependencyValues {
  var userNotifications: UserNotificationClient {
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

public extension UserNotificationClient {
  static let noop = Self(
    notificationSettings: { UNAuthorizationStatus.notDetermined },
    requestAuthorization: { _ in false }
  )
}
