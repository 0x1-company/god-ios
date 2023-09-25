import FirebaseAnalytics

public struct AnalyticsClient {
  public var logEvent: @Sendable (_ name: String, _ parameters: [String: Any]?) -> Void
  public var setUserId: @Sendable (String) -> Void
  public var setUserProperty: @Sendable (_ forName: String, _ value: String?) -> Void
  public var setAnalyticsCollectionEnabled: @Sendable (Bool) -> Void
}

public extension AnalyticsClient {
  func logScreen<T>(screenName: String, of value: T) {
    logEvent(
      AnalyticsEventScreenView,
      [
        AnalyticsParameterScreenName: screenName,
        AnalyticsParameterScreenClass: String(describing: type(of: value)),
      ]
    )
  }
}
