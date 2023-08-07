import Dependencies
import PhoneNumberKit

extension PhoneNumberClient: DependencyKey {
  public static let liveValue: Self = {
    let phoneNumberKit = PhoneNumberKit()
    return Self(
      parse: phoneNumberKit.parse(_:withRegion:ignoreType:),
      format: phoneNumberKit.format(_:toType:withPrefix:)
    )
  }()
}
