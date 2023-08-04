import Contacts

public struct ContactsClient {
  public var authorizationStatus: (CNEntityType) -> CNAuthorizationStatus
  public var requestAccess: (CNEntityType) async throws -> Bool
  public var enumerateContacts: @Sendable (CNContactFetchRequest) async throws -> (CNContact, UnsafeMutablePointer<ObjCBool>)
}
