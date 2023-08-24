import Dependencies
import XCTestDynamicOverlay

public extension DependencyValues {
  var godClient: GodClient {
    get { self[GodClient.self] }
    set { self[GodClient.self] = newValue }
  }
}

extension GodClient: TestDependencyKey {
  public static let testValue = Self(
    updateUsername: unimplemented("\(Self.self).updateUsername"),
    updateUserProfile: unimplemented("\(Self.self).updateUserProfile"),
    store: unimplemented("\(Self.self).store")
  )
}
