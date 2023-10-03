import Foundation

public struct UserDefaultsClient {
  public var boolForKey: @Sendable (String) -> Bool
  public var dataForKey: @Sendable (String) -> Data?
  public var doubleForKey: @Sendable (String) -> Double
  public var integerForKey: @Sendable (String) -> Int
  public var stringForKey: @Sendable (String) -> String?
  public var remove: @Sendable (String) async -> Void
  public var setBool: @Sendable (Bool, String) async -> Void
  public var setData: @Sendable (Data?, String) async -> Void
  public var setDouble: @Sendable (Double, String) async -> Void
  public var setInteger: @Sendable (Int, String) async -> Void
  public var setString: @Sendable (String?, String) async -> Void
}

public extension UserDefaultsClient {
  func setCodable(_ value: Codable, forKey key: String) async {
    let data = try? encoder.encode(value)
    return await setData(data, key)
  }

  func codableForKey<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
    guard let data = dataForKey(key) else { return nil }
    return try? decoder.decode(T.self, from: data)
  }

  func setPhoneNumber(_ value: String) async {
    await setString(value, keyPhoneNumber)
  }

  func phoneNumber() -> String? {
    stringForKey(keyPhoneNumber)
  }

  func setVerificationId(_ value: String) async {
    await setString(value, keyVerificationId)
  }

  func verificationId() -> String? {
    stringForKey(keyVerificationId)
  }

  func setOnboardCompleted(_ value: Bool) async {
    await setBool(value, keyOnboardCompleted)
  }

  func onboardCompleted() -> Bool {
    boolForKey(keyOnboardCompleted)
  }

  func setReadInitialGodTeamNotification() async {
    await setBool(true, keyReadInitialGodTeamNotification)
  }

  func readInitialGodTeamNotification() -> Bool {
    boolForKey(keyReadInitialGodTeamNotification)
  }
  
  func setDynamicLinkURL(_ value: String?) async {
    await setString(value, keyDynamicLinkURL)
  }
  
  func dynamicLinkURL() -> String? {
    stringForKey(keyDynamicLinkURL)
  }
}

private let keyPhoneNumber = "PHONE_NUMBER"
private let keyVerificationId = "VERIFICATION_ID"
private let keyOnboardCompleted = "ONBOARD_COMPLETED"
private let keyReadInitialGodTeamNotification = "READ_INITIAL_GOD_TEAM_NOTIFICATION"
private let keyDynamicLinkURL = "DYNAMIC_LINK_URL"

private let decoder = JSONDecoder()
private let encoder = JSONEncoder()
