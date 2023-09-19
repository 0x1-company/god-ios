import Dependencies
import PhoneNumberKit

public extension DependencyValues {
  var phoneNumberParse: PhoneNumberParseEffect {
    get { self[PhoneNumberParseKey.self] }
    set { self[PhoneNumberParseKey.self] = newValue }
  }
}

private enum PhoneNumberParseKey: DependencyKey {
  static let liveValue = PhoneNumberParseEffect()
  static let testValue = PhoneNumberParseEffect()
}

public struct PhoneNumberParseEffect: Sendable {
  public func callAsFunction(_ numberString: String) throws -> PhoneNumber {
    try callAsFunction(numberString, withRegion: PhoneNumberKit.defaultRegionCode(), ignoreType: false)
  }

  public func callAsFunction(_ numberString: String, ignoreType: Bool) throws -> PhoneNumber {
    try callAsFunction(numberString, withRegion: PhoneNumberKit.defaultRegionCode(), ignoreType: ignoreType)
  }

  public func callAsFunction(_ numberString: String, withRegion region: String = PhoneNumberKit.defaultRegionCode(), ignoreType: Bool = false) throws -> PhoneNumber {
    let phoneNumberKit = PhoneNumberKit()
    return try phoneNumberKit.parse(numberString, withRegion: region, ignoreType: ignoreType)
  }
}
