import Dependencies
import PhoneNumberKit

public extension DependencyValues {
  var phoneNumberFormat: @Sendable (PhoneNumber) -> String {
    get { self[PhoneNumberFormatKey.self] }
    set { self[PhoneNumberFormatKey.self] = newValue }
  }

  private enum PhoneNumberFormatKey: DependencyKey {
    typealias Value = @Sendable (PhoneNumber) -> String

    static let liveValue: Value = { phoneNumber in
      let phoneNumberKit = PhoneNumberKit()
      return phoneNumberKit.format(phoneNumber, toType: .e164)
    }
  }
}
