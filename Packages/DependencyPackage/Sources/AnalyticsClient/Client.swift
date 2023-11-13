import FirebaseAnalytics

public struct AnalyticsClient {
  public var logEvent: @Sendable (_ name: String, _ parameters: [String: Any]?) -> Void
  public var setUserId: @Sendable (String) -> Void
  public var setUserProperty: @Sendable (_ forName: String, _ value: String?) -> Void
  public var setAnalyticsCollectionEnabled: @Sendable (Bool) -> Void
}

public extension AnalyticsClient {
  func logScreen(screenName: String, of value: some Any, parameters: [String: Any] = [:]) {
    var parameters = parameters
    parameters[AnalyticsParameterScreenName] = screenName
    parameters[AnalyticsParameterScreenClass] = String(describing: type(of: value))
    logEvent(
      AnalyticsEventScreenView,
      parameters
    )
  }

  func signUp() {
    logEvent(AnalyticsEventSignUp, [:])
  }
}

public extension AnalyticsClient {
  func log(name: String, parameters: [String: Any]) {
    var parameters = parameters
    parameters["name"] = name
    logEvent("log", parameters)
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

public extension AnalyticsClient {
  func buttonClick(name: ButtonClickName, parameters: [String: Any] = [:]) {
    buttonClick(name.rawValue, parameters: parameters)
  }

  func buttonClick(_ name: String, parameters: [String: Any] = [:]) {
    var parameters = parameters
    parameters["name"] = name
    logEvent("button_click", parameters)
  }

  enum ButtonClickName: String {
    case close
    case voteSlowDown = "vote_slow_down"
    case shuffle
    case skip
    case storyShare = "story_share"
    case lineShare = "line_share"
    case smsShare = "sms_share"
    case editProfile = "edit_profile"
    case shareProfile = "share_profile"
    case shop
    case shareOnInstagram = "share_on_instagram"
    case copyLink = "copy_link"
    case addFriends = "add_friends"
    case inviteFriend = "invite_friend"
    case notNow = "not_now"
    case delete
    case gmail
    case email
    case forceUpdate = "force_update"
    case howItWorks = "how_it_works"
    case faq
    case shareFeedback = "share_feedback"
    case getHelp = "get_help"
    case safetyCenter = "safety_center"
    case requiredInviteFriend = "required_invite_friend"
  }
}
