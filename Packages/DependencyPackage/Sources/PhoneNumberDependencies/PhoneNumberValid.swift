import Dependencies
import PhoneNumberKit

public extension DependencyValues {
  var isValidPhoneNumber: @Sendable (String) -> Bool {
    get { self[IsValidPhoneNumberKey.self] }
    set { self[IsValidPhoneNumberKey.self] = newValue }
  }
  
  private enum IsValidPhoneNumberKey: DependencyKey {
    typealias Value = @Sendable (String) -> Bool
    
    static let liveValue: Value = { numberString in
      let phoneNumberKit = PhoneNumberKit()
      return phoneNumberKit.isValidPhoneNumber(numberString, withRegion: "JP", ignoreType: true)
    }
  }
}
