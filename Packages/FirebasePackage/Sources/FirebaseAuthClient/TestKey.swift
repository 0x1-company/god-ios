import Dependencies
import XCTestDynamicOverlay

public extension DependencyValues {
  var firebaseAuth: FirebaseAuthClient {
    get { self[FirebaseAuthClient.self] }
    set { self[FirebaseAuthClient.self] = newValue }
  }
}

extension FirebaseAuthClient: TestDependencyKey {
  public static let testValue = Self(
    verifyPhoneNumber: unimplemented("\(Self.self).verifyPhoneNumber")
  )
}
