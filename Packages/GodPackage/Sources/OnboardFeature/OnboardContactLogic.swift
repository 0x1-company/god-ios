import ComposableArchitecture
import ContactsClient
import God
import PhoneNumberDependencies

@Reducer
public struct OnboardContactLogic {
  @Dependency(\.phoneNumberParse) var phoneNumberParse
  @Dependency(\.phoneNumberFormat) var phoneNumberFormat
  @Dependency(\.contacts.enumerateContacts) var enumerateContacts
  @Dependency(\.contacts.authorizationStatus) var authorizationStatus

  var isFindFriendSkip: Bool {
    authorizationStatus(.contacts) != .notDetermined
  }

  public func reduce(
    into state: inout OnboardLogic.State,
    action: OnboardLogic.Action
  ) -> Effect<OnboardLogic.Action> {
    switch action {
    case let .contactResponse(.success(contact)):
      guard
        let number = contact.phoneNumbers.first?.value.stringValue,
        let phoneNumber = try? phoneNumberParse(number)
      else {
        return .none
      }
      let countryCode = "+" + String(phoneNumber.countryCode)
      let format = phoneNumberFormat(phoneNumber)

      guard countryCode == "+81" else { return .none }

      if contact.familyName.isEmpty, contact.givenName.isEmpty {
        return .none
      }

      state.contacts.append(
        God.ContactInput(
          name: "\(contact.familyName) \(contact.givenName)",
          phoneNumber: God.PhoneNumberInput(
            countryCode: countryCode,
            numbers: format.replacing(countryCode, with: "")
          )
        )
      )
      return .none
    default:
      return .none
    }
  }
}
