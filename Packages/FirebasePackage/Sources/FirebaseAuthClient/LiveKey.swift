import Dependencies
import FirebaseAuth

extension FirebaseAuthClient: DependencyKey {
  public static let liveValue = Self(
    languageCode: { Auth.auth().languageCode = $0 },
    signOut: { try Auth.auth().signOut() },
    canHandle: { Auth.auth().canHandle($0) },
    canHandleNotification: { Auth.auth().canHandleNotification($0) },
    setAPNSToken: { Auth.auth().setAPNSToken($0, type: $1) },
    verifyPhoneNumber: { phoneNumber in
      try await withCheckedThrowingContinuation { continuation in
        PhoneAuthProvider.provider()
          .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error {
              continuation.resume(throwing: error)
            } else {
              continuation.resume(returning: verificationID)
            }
          }
      }
    },
    credential: { PhoneAuthProvider.provider().credential(withVerificationID: $0, verificationCode: $1) }
  )
}
