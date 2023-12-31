// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class Mutation: MockObject {
  public static let objectType: Object = God.Objects.Mutation
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Mutation>>

  public struct MockFields {
    @Field<Friend>("approveFriendRequest") public var approveFriendRequest
    @Field<CompletePollResponse>("completePoll") public var completePoll
    @Field<Bool>("createContacts") public var createContacts
    @Field<FirebaseRegistrationToken>("createFirebaseRegistrationToken") public var createFirebaseRegistrationToken
    @Field<Friend>("createFriendRequest") public var createFriendRequest
    @Field<Bool>("createTransaction") public var createTransaction
    @Field<User>("createUser") public var createUser
    @Field<UserBlock>("createUserBlock") public var createUserBlock
    @Field<UserHide>("createUserHide") public var createUserHide
    @Field<Vote>("createVote") public var createVote
    @Field<Bool>("purchase") public var purchase
    @Field<InboxActivity>("readActivity") public var readActivity
    @Field<LocalizableString>("revealFullName") public var revealFullName
    @Field<User>("updateUserProfile") public var updateUserProfile
    @Field<User>("updateUsername") public var updateUsername
  }
}

public extension Mock where O == Mutation {
  convenience init(
    approveFriendRequest: Mock<Friend>? = nil,
    completePoll: Mock<CompletePollResponse>? = nil,
    createContacts: Bool? = nil,
    createFirebaseRegistrationToken: Mock<FirebaseRegistrationToken>? = nil,
    createFriendRequest: Mock<Friend>? = nil,
    createTransaction: Bool? = nil,
    createUser: Mock<User>? = nil,
    createUserBlock: Mock<UserBlock>? = nil,
    createUserHide: Mock<UserHide>? = nil,
    createVote: Mock<Vote>? = nil,
    purchase: Bool? = nil,
    readActivity: Mock<InboxActivity>? = nil,
    revealFullName: Mock<LocalizableString>? = nil,
    updateUserProfile: Mock<User>? = nil,
    updateUsername: Mock<User>? = nil
  ) {
    self.init()
    _setEntity(approveFriendRequest, for: \.approveFriendRequest)
    _setEntity(completePoll, for: \.completePoll)
    _setScalar(createContacts, for: \.createContacts)
    _setEntity(createFirebaseRegistrationToken, for: \.createFirebaseRegistrationToken)
    _setEntity(createFriendRequest, for: \.createFriendRequest)
    _setScalar(createTransaction, for: \.createTransaction)
    _setEntity(createUser, for: \.createUser)
    _setEntity(createUserBlock, for: \.createUserBlock)
    _setEntity(createUserHide, for: \.createUserHide)
    _setEntity(createVote, for: \.createVote)
    _setScalar(purchase, for: \.purchase)
    _setEntity(readActivity, for: \.readActivity)
    _setEntity(revealFullName, for: \.revealFullName)
    _setEntity(updateUserProfile, for: \.updateUserProfile)
    _setEntity(updateUsername, for: \.updateUsername)
  }
}
