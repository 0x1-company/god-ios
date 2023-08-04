import Contacts
import Dependencies

extension ContactsClient: DependencyKey {
  public static let liveValue: Self = {
    let store = CNContactStore()
    return Self(
      authorizationStatus: CNContactStore.authorizationStatus(for:),
      requestAccess: store.requestAccess(for:),
      enumerateContacts: { request in
        return try await withCheckedThrowingContinuation { continuation in
          do {
            try store.enumerateContacts(with: request) { contact, pointer in
              continuation.resume(with: .success((contact, pointer)))
            }
          } catch {
            continuation.resume(throwing: error)
          }
        }
      }
    )
  }()
}
