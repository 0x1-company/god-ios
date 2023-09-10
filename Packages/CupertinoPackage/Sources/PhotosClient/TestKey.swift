import Dependencies
import XCTestDynamicOverlay

public extension DependencyValues {
  var photos: PhotosClient {
    get { self[PhotosClient.self] }
    set { self[PhotosClient.self] = newValue }
  }
}

extension PhotosClient: TestDependencyKey {
  public static let testValue = Self(
    requestAuthorization: unimplemented("\(Self.self).requestAuthorization"),
    authorizationStatus: unimplemented("\(Self.self).authorizationStatus"),
    requestImage: unimplemented("\(Self.self).requestImage", placeholder: .finished),
    performChanges: unimplemented("\(Self.self).performChanges")
  )
}
