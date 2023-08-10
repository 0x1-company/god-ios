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
    currentUser: unimplemented("\(Self.self).currentUser"),
    languageCode: unimplemented("\(Self.self).languageCode"),
    signOut: unimplemented("\(Self.self).signOut"),
    canHandle: unimplemented("\(Self.self).canHandle"),
    canHandleNotification: unimplemented("\(Self.self).canHandleNotification"),
    setAPNSToken: unimplemented("\(Self.self).setAPNSToken"),
    verifyPhoneNumber: unimplemented("\(Self.self).verifyPhoneNumber"),
    credential: unimplemented("\(Self.self).credential"),
    signIn: unimplemented("\(Self.self).signIn")
  )
}
