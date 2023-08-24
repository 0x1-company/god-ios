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
    createUserBlock: unimplemented("\(Self.self)."),
    createUserHide: unimplemented("\(Self.self)."),
    createUser: unimplemented("\(Self.self)."),
    createFriendRequest: unimplemented("\(Self.self)."),
    approveFriendRequest: unimplemented("\(Self.self)."),
    store: unimplemented("\(Self.self).store")
  )
}
