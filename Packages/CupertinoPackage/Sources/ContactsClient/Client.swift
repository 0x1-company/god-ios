import Contacts

public struct ContactsClient {
  public var authorizationStatus: (CNEntityType) -> CNAuthorizationStatus
  public var requestAccess: (CNEntityType) async throws -> Bool
  public var enumerateContacts: @Sendable (CNContactFetchRequest) async throws -> (CNContact, UnsafeMutablePointer<ObjCBool>)
  public var unifiedContacts: @Sendable (NSPredicate, [CNKeyDescriptor]) throws -> [CNContact]
}

public extension ContactsClient {
  func findByPhoneNumber(number: String) throws -> [CNContact] {
    let phoneNumberPredicate = CNPhoneNumber(stringValue: number)
    let predicate = CNContact.predicateForContacts(matching: phoneNumberPredicate)
    let keysToFetch: [CNKeyDescriptor] = [
      CNContactPhoneticGivenNameKey as CNKeyDescriptor,
      CNContactPhoneticFamilyNameKey as CNKeyDescriptor,
      CNContactPhoneNumbersKey as CNKeyDescriptor,
    ]
    return try unifiedContacts(predicate, keysToFetch)
  }
}
