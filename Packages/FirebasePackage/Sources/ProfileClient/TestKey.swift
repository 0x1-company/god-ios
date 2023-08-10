import Dependencies
import XCTestDynamicOverlay

public extension DependencyValues {
  var profileClient: ProfileClient {
    get { self[ProfileClient.self] }
    set { self[ProfileClient.self] = newValue }
  }
}

extension ProfileClient: TestDependencyKey {
  public static let testValue = Self(
    user: unimplemented("\(Self.self).user")
  )
}
