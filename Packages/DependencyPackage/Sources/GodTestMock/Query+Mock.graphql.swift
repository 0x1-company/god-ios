// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class Query: MockObject {
  public static let objectType: Object = God.Objects.Query
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Query>>

  public struct MockFields {
    @Field<User>("currentUser") public var currentUser
    @Field<FriendConnection>("friendRequests") public var friendRequests
    @Field<[User]>("friends") public var friends
    @Field<UserConnection>("friendsOfFriends") public var friendsOfFriends
    @Field<ActivityConnection>("listActivities") public var listActivities
    @Field<Store>("store") public var store
    @Field<User>("user") public var user
    @Field<UserConnection>("usersBySchoolId") public var usersBySchoolId
  }
}

public extension Mock where O == Query {
  convenience init(
    currentUser: Mock<User>? = nil,
    friendRequests: Mock<FriendConnection>? = nil,
    friends: [Mock<User>]? = nil,
    friendsOfFriends: Mock<UserConnection>? = nil,
    listActivities: Mock<ActivityConnection>? = nil,
    store: Mock<Store>? = nil,
    user: Mock<User>? = nil,
    usersBySchoolId: Mock<UserConnection>? = nil
  ) {
    self.init()
    _setEntity(currentUser, for: \.currentUser)
    _setEntity(friendRequests, for: \.friendRequests)
    _setList(friends, for: \.friends)
    _setEntity(friendsOfFriends, for: \.friendsOfFriends)
    _setEntity(listActivities, for: \.listActivities)
    _setEntity(store, for: \.store)
    _setEntity(user, for: \.user)
    _setEntity(usersBySchoolId, for: \.usersBySchoolId)
  }
}
