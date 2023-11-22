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
    @Field<[Banner]>("banners") public var banners
    @Field<[ClubActivity]>("clubActivities") public var clubActivities
    @Field<CurrentPoll>("currentPoll") public var currentPoll
    @Field<User>("currentUser") public var currentUser
    @Field<FriendConnection>("friendRequests") public var friendRequests
    @Field<[User]>("friends") public var friends
    @Field<UserConnection>("friendsOfFriends") public var friendsOfFriends
    @Field<InboxActivity>("inboxActivity") public var inboxActivity
    @Field<InvitationCode>("invitationCode") public var invitationCode
    @Field<ActivityConnection>("listActivities") public var listActivities
    @Field<InboxActivityConnection>("listInboxActivities") public var listInboxActivities
    @Field<[Question]>("questionsOrderByVotedDesc") public var questionsOrderByVotedDesc
    @Field<Int>("revealFullNameLimit") public var revealFullNameLimit
    @Field<SchoolConnection>("schools") public var schools
    @Field<Store>("store") public var store
    @Field<User>("user") public var user
    @Field<User>("userSearch") public var userSearch
    @Field<UserConnection>("usersBySameSchool") public var usersBySameSchool
  }
}

public extension Mock where O == Query {
  convenience init(
    activeSubscription: Mock<Subscription>? = nil,
    banners: [Mock<Banner>]? = nil,
    clubActivities: [Mock<ClubActivity>]? = nil,
    currentPoll: Mock<CurrentPoll>? = nil,
    currentUser: Mock<User>? = nil,
    friendRequests: Mock<FriendConnection>? = nil,
    friends: [Mock<User>]? = nil,
    friendsOfFriends: Mock<UserConnection>? = nil,
    inboxActivity: Mock<InboxActivity>? = nil,
    invitationCode: Mock<InvitationCode>? = nil,
    listActivities: Mock<ActivityConnection>? = nil,
    listInboxActivities: Mock<InboxActivityConnection>? = nil,
    questionsOrderByVotedDesc: [Mock<Question>]? = nil,
    revealFullNameLimit: Int? = nil,
    schools: Mock<SchoolConnection>? = nil,
    store: Mock<Store>? = nil,
    user: Mock<User>? = nil,
    userSearch: Mock<User>? = nil,
    usersBySameSchool: Mock<UserConnection>? = nil
  ) {
    self.init()
    _setEntity(activeSubscription, for: \.activeSubscription)
    _setList(banners, for: \.banners)
    _setList(clubActivities, for: \.clubActivities)
    _setEntity(currentPoll, for: \.currentPoll)
    _setEntity(currentUser, for: \.currentUser)
    _setEntity(friendRequests, for: \.friendRequests)
    _setList(friends, for: \.friends)
    _setEntity(friendsOfFriends, for: \.friendsOfFriends)
    _setEntity(inboxActivity, for: \.inboxActivity)
    _setEntity(invitationCode, for: \.invitationCode)
    _setEntity(listActivities, for: \.listActivities)
    _setEntity(listInboxActivities, for: \.listInboxActivities)
    _setList(questionsOrderByVotedDesc, for: \.questionsOrderByVotedDesc)
    _setScalar(revealFullNameLimit, for: \.revealFullNameLimit)
    _setEntity(schools, for: \.schools)
    _setEntity(store, for: \.store)
    _setEntity(user, for: \.user)
    _setEntity(userSearch, for: \.userSearch)
    _setEntity(usersBySameSchool, for: \.usersBySameSchool)
  }
}
