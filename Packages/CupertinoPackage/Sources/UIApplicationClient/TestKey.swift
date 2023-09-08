import Dependencies
import XCTestDynamicOverlay

public extension DependencyValues {
  var application: UIApplicationClient {
    get { self[UIApplicationClient.self] }
    set { self[UIApplicationClient.self] = newValue }
  }
}

extension UIApplicationClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self(
    openSettingsURLString: unimplemented("\(Self.self).openSettingsURLString"),
    openNotificationSettingsURLString: unimplemented("\(Self.self).openNotificationSettingsURLString")
  )
}

public extension UIApplicationClient {
  static let noop = Self(
    openSettingsURLString: { "settings://god/settings" },
    openNotificationSettingsURLString: { "" }
  )
}
