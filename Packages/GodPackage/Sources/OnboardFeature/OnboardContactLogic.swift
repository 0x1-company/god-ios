import ComposableArchitecture
import ContactsClient
import God
import PhoneNumberClient

public struct OnboardContactLogic: Reducer {
  @Dependency(\.phoneNumberClient) var phoneNumberClient
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
        let format = try? phoneNumberClient.parseFormat(number)
      else {
        return .none
      }
      
      state.contacts.append(
        God.ContactInput(
          name: contact.familyName + contact.givenName,
          phoneNumber: God.PhoneNumberInput(
            countryCode: "+81",
            numbers: format.replacing("+81", with: "")
          )
        )
      )
      return .none
    default:
      return .none
    }
  }
}
