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
    requestImage: unimplemented("\(Self.self).requestImage", placeholder: .finished)
  )
}
