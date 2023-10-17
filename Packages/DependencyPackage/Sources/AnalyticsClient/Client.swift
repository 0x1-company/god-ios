import FirebaseAnalytics

public struct AnalyticsClient {
  public var logEvent: @Sendable (_ name: String, _ parameters: [String: Any]?) -> Void
  public var setUserId: @Sendable (String) -> Void
  public var setUserProperty: @Sendable (_ forName: String, _ value: String?) -> Void
  public var setAnalyticsCollectionEnabled: @Sendable (Bool) -> Void
}

public extension AnalyticsClient {
  func logScreen(screenName: String, of value: some Any) {
    logEvent(
      AnalyticsEventScreenView,
      [
        AnalyticsParameterScreenName: screenName,
        AnalyticsParameterScreenClass: String(describing: type(of: value)),
      ]
    )
  }

  func buttonClick(name: String, parameters: [String: Any] = [:]) {
    var parameters = parameters
    parameters["name"] = name
    logEvent("button_click", parameters)
  }
}

public extension AnalyticsClient {
  func setUserProperty(key: UserProperty, value: String?) {
    setUserProperty(key.rawValue, value)
    print("[AnalyticsClient][setUserProperty] Changed [key: \(key.rawValue), value: \(value ?? "NULL")]")
  }

  enum UserProperty: String {
    case uid
    case gender
    case generation
    case schoolId = "school_id"
  }
}
