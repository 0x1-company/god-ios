import PhoneNumberKit

public struct PhoneNumberClient {
  public var parse: (String, String, Bool) throws -> PhoneNumber
  public var format: (PhoneNumber, PhoneNumberFormat, Bool) -> String
}

extension PhoneNumberClient {
  public func parseFormat(_ phoneNumber: String) throws -> String {
    let content = try self.parse(phoneNumber, "JP", true)
    let formatPhoneNumber = self.format(content, .e164, true)
    return formatPhoneNumber
  }
}
