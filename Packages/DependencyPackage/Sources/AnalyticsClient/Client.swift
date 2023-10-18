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
    var parameters = parameters
    parameters["name"] = name.rawValue
    logEvent("button_click", parameters)
  }

  enum ButtonClickName: String {
    case vote
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
  }
}
