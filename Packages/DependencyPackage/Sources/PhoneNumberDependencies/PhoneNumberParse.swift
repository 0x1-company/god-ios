import Dependencies
import PhoneNumberKit

public extension DependencyValues {
  var phoneNumberParse: @Sendable (String) throws -> PhoneNumber {
    get { self[PhoneNumberParseKey.self] }
    set { self[PhoneNumberParseKey.self] = newValue }
  }
  
  private enum PhoneNumberParseKey: DependencyKey {
    typealias Value = @Sendable (String) throws -> PhoneNumber
    
    static let liveValue: Value = { numberString in
      let phoneNumberKit = PhoneNumberKit()
      return try phoneNumberKit.parse(numberString, ignoreType: true)
    }
  }
}
