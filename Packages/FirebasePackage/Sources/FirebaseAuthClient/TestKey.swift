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
    languageCode: unimplemented("\(Self.self).languageCode"),
    signOut: unimplemented("\(Self.self).signOut"),
    verifyPhoneNumber: unimplemented("\(Self.self).verifyPhoneNumber")
  )
}
