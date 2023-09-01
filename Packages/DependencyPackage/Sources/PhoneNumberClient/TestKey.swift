import Dependencies
import XCTestDynamicOverlay

public extension DependencyValues {
  var phoneNumberClient: PhoneNumberClient {
    get { self[PhoneNumberClient.self] }
    set { self[PhoneNumberClient.self] = newValue }
  }
}

extension PhoneNumberClient: TestDependencyKey {
  public static let testValue = Self(
    parse: unimplemented("\(Self.self).parse"),
    format: unimplemented("\(Self.self).format"),
    isValidPhoneNumber: unimplemented("\(Self.self).isValidPhoneNumber")
  )
}
