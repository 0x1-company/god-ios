import Dependencies
import XCTestDynamicOverlay

public extension DependencyValues {
  var analytics: AnalyticsClient {
    get { self[AnalyticsClient.self] }
    set { self[AnalyticsClient.self] = newValue }
  }
}

extension AnalyticsClient: TestDependencyKey {
  public static let testValue = Self(
    logEvent: unimplemented("\(Self.self).logEvent"),
    setUserId: unimplemented("\(Self.self).setUserId"),
    setUserProperty: unimplemented("\(Self.self).setUserProperty"),
    setAnalyticsCollectionEnabled: unimplemented("\(Self.self).setAnalyticsCollectionEnabled")
  )
}

public extension AnalyticsClient {
  static let noop = Self(
    logEvent: { _, _ in },
    setUserId: { _ in },
    setUserProperty: { _, _ in },
    setAnalyticsCollectionEnabled: { _ in }
  )
}
