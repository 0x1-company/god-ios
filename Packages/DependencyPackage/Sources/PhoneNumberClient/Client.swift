import PhoneNumberKit

public struct PhoneNumberClient {
  public var parse: (String, String, Bool) throws -> PhoneNumber
  public var format: (PhoneNumber, PhoneNumberFormat, Bool) -> String
}

public extension PhoneNumberClient {
  func parseFormat(_ phoneNumber: String) throws -> String {
    let content = try parse(phoneNumber, "JP", true)
    let formatPhoneNumber = format(content, .e164, true)
    return formatPhoneNumber
  }
}
