// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class Query: MockObject {
  public static let objectType: Object = God.Objects.Query
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Query>>

  public struct MockFields {
    @Field<Subscription>("activeSubscription") public var activeSubscription
    @Field<CurrentPoll>("currentPoll") public var currentPoll
    @Field<User>("currentUser") public var currentUser
    @Field<FriendConnection>("friendRequests") public var friendRequests
    @Field<[User]>("friends") public var friends
    @Field<UserConnection>("friendsOfFriends") public var friendsOfFriends
    @Field<ActivityConnection>("listActivities") public var listActivities
    @Field<InboxActivityConnection>("listInboxActivities") public var listInboxActivities
    @Field<Int>("revealFullNameLimit") public var revealFullNameLimit
    @Field<Store>("store") public var store
    @Field<User>("user") public var user
    @Field<UserConnection>("usersBySchoolId") public var usersBySchoolId
  }
}

public extension Mock where O == Query {
  convenience init(
    activeSubscription: Mock<Subscription>? = nil,
    currentPoll: Mock<CurrentPoll>? = nil,
    currentUser: Mock<User>? = nil,
    friendRequests: Mock<FriendConnection>? = nil,
    friends: [Mock<User>]? = nil,
    friendsOfFriends: Mock<UserConnection>? = nil,
    listActivities: Mock<ActivityConnection>? = nil,
    listInboxActivities: Mock<InboxActivityConnection>? = nil,
    revealFullNameLimit: Int? = nil,
    store: Mock<Store>? = nil,
    user: Mock<User>? = nil,
    usersBySchoolId: Mock<UserConnection>? = nil
  ) {
    self.init()
    _setEntity(activeSubscription, for: \.activeSubscription)
    _setEntity(currentPoll, for: \.currentPoll)
    _setEntity(currentUser, for: \.currentUser)
    _setEntity(friendRequests, for: \.friendRequests)
    _setList(friends, for: \.friends)
    _setEntity(friendsOfFriends, for: \.friendsOfFriends)
    _setEntity(listActivities, for: \.listActivities)
    _setEntity(listInboxActivities, for: \.listInboxActivities)
    _setScalar(revealFullNameLimit, for: \.revealFullNameLimit)
    _setEntity(store, for: \.store)
    _setEntity(user, for: \.user)
    _setEntity(usersBySchoolId, for: \.usersBySchoolId)
  }
}
