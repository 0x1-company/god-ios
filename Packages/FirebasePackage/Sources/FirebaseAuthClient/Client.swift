public struct FirebaseAuthClient {
  public var verifyPhoneNumber: @Sendable (String) async throws -> String?
}
