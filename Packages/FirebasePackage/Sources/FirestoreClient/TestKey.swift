import Dependencies
import XCTestDynamicOverlay

public extension DependencyValues {
  var firestore: FirestoreClient {
    get { self[FirestoreClient.self] }
    set { self[FirestoreClient.self] = newValue }
  }
}

extension FirestoreClient: TestDependencyKey {
  public static let testValue = Self(
    config: unimplemented("\(Self.self).config")
  )
}
