import FirebaseAuth
import Foundation

public struct FirebaseAuthClient {
  public var addStateDidChangeListener: @Sendable () -> AsyncStream<User?>
  public var languageCode: @Sendable (String?) -> Void
  public var signOut: @Sendable () throws -> Void
  public var canHandle: @Sendable (URL) -> Bool
  public var canHandleNotification: @Sendable ([AnyHashable: Any]) -> Bool
  public var setAPNSToken: @Sendable (Data, AuthAPNSTokenType) -> Void
  public var verifyPhoneNumber: @Sendable (String) async throws -> String?
  public var credential: @Sendable (String, String) -> PhoneAuthCredential
  public var signIn: @Sendable (PhoneAuthCredential) async throws -> AuthDataResult?
}
