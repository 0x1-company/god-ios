import Dependencies
import FirebaseAuth

extension FirebaseAuthClient: DependencyKey {
  public static let liveValue = Self(
    languageCode: { Auth.auth().languageCode = $0 },
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
    }
  )
}
