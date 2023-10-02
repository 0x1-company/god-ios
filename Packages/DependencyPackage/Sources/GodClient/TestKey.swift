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
    currentUserProfile: unimplemented("\(Self.self).profile"),
    peopleYouMayKnow: unimplemented("\(Self.self).peopleYouMayKnow"),
    schools: unimplemented("\(Self.self).schools"),
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
    friendRequests: unimplemented("\(Self.self).friendRequests"),
    createFriendRequest: unimplemented("\(Self.self).createFriendRequest"),
    approveFriendRequest: unimplemented("\(Self.self).approveFriendRequest"),
    addPlus: unimplemented("\(Self.self).addPlus"),
    createFirebaseRegistrationToken: unimplemented("\(Self.self).createFirebaseRegistrationToken"),
    createContacts: unimplemented("\(Self.self).createContacts"),
    createTransaction: unimplemented("\(Self.self).createTransaction"),
    activeSubscription: unimplemented("\(Self.self).activeSubscription"),
    revealFullNameLimit: unimplemented("\(Self.self).revealFullNameLimit"),
    revealFullName: unimplemented("\(Self.self).revealFullName")
  )
}
