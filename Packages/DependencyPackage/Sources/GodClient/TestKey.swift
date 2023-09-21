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
    user: unimplemented("\(Self.self).user"),
    currentUser: unimplemented("\(Self.self).currentUser"),
    profile: unimplemented("\(Self.self).profile"),
    schools: unimplemented("\(Self.self).schools"),
    createFriendRequest: unimplemented("\(Self.self).createFriendRequest"),
    approveFriendRequest: unimplemented("\(Self.self).approveFriendRequest"),
    store: unimplemented("\(Self.self).store"),
    purchase: unimplemented("\(Self.self).purchase"),
    readActivity: unimplemented("\(Self.self).readActivity"),
    activities: unimplemented("\(Self.self).activities"),
    inboxActivities: unimplemented("\(Self.self).inboxActivities"),
    currentPoll: unimplemented("\(Self.self).currentPoll"),
    createVote: unimplemented("\(Self.self).createVote"),
    completePoll: unimplemented("\(Self.self).completePoll"),
    friends: unimplemented("\(Self.self).friends"),
    friendsOfFriends: unimplemented("\(Self.self).friendsOfFriends"),
    fromSchools: unimplemented("\(Self.self).fromSchools"),
    friendRequests: unimplemented("\(Self.self).friendRequests"),
    createFirebaseRegistrationToken: unimplemented("\(Self.self).createFirebaseRegistrationToken"),
    createContacts: unimplemented("\(Self.self).createContacts"),
    createTransaction: unimplemented("\(Self.self).createTransaction"),
    activeSubscription: unimplemented("\(Self.self).activeSubscription"),
    revealFullNameLimit: unimplemented("\(Self.self).revealFullNameLimit"),
    revealFullName: unimplemented("\(Self.self).revealFullName")
  )
}
