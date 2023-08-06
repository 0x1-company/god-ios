public struct FirebaseAuthClient {
  public var languageCode: @Sendable (String?) -> Void
  public var verifyPhoneNumber: @Sendable (String) async throws -> String?
}
