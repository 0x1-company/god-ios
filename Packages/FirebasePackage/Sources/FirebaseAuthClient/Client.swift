import Foundation
import FirebaseAuth

public struct FirebaseAuthClient {
  public var languageCode: @Sendable (String?) -> Void
  public var signOut: @Sendable () throws -> Void
  public var verifyPhoneNumber: @Sendable (String) async throws -> String?
  public var canHandle: @Sendable (URL) -> Bool
  public var canHandleNotification: @Sendable ([AnyHashable : Any]) -> Bool
  public var setAPNSToken: @Sendable (Data, AuthAPNSTokenType) -> Void
}
