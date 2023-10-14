import Dependencies
import XCTestDynamicOverlay

public extension DependencyValues {
  var userSettings: UserSettingsClient {
    get { self[UserSettingsClient.self] }
    set { self[UserSettingsClient.self] = newValue }
  }
}

extension UserSettingsClient: TestDependencyKey {
  public static let testValue = Self(
    contact: unimplemented("\(Self.self).contact"),
    notification: unimplemented("\(Self.self).notification")
  )
}
