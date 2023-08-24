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
    createUserBlock: unimplemented("\(Self.self).createUserBlock"),
    createUserHide: unimplemented("\(Self.self).createUserHide"),
    createUser: unimplemented("\(Self.self).createUser"),
    createFriendRequest: unimplemented("\(Self.self).createFriendRequest"),
    approveFriendRequest: unimplemented("\(Self.self).approveFriendRequest"),
    store: unimplemented("\(Self.self).store")
  )
}
