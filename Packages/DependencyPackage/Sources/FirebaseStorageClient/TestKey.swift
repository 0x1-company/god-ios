import Dependencies
import XCTestDynamicOverlay

public extension DependencyValues {
  var firebaseStorage: FirebaseStorageClient {
    get { self[FirebaseStorageClient.self] }
    set { self[FirebaseStorageClient.self] = newValue }
  }
}

extension FirebaseStorageClient: TestDependencyKey {
  public static let testValue = Self(
    upload: unimplemented("\(Self.self).upload")
  )
}
