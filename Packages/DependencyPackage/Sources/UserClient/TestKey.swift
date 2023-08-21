import Dependencies
import XCTestDynamicOverlay

public extension DependencyValues {
  var user: UserClient {
    get { self[UserClient.self] }
    set { self[UserClient.self] = newValue }
  }
}

extension UserClient: TestDependencyKey {
  public static let testValue = Self(
    updateUsername: unimplemented("\(Self.self).updateUsername")
  )
}
