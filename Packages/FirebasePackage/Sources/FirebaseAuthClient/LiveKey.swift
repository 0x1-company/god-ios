import Dependencies
import FirebaseAuth

extension FirebaseAuthClient: DependencyKey {
  public static let liveValue = Self(
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
