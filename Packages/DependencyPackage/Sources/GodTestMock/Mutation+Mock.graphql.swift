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
    @Field<FirebaseRegistrationToken>("createFirebaseRegistrationToken") public var createFirebaseRegistrationToken
    @Field<Friend>("createFriendRequest") public var createFriendRequest
    @Field<User>("createUser") public var createUser
    @Field<UserBlock>("createUserBlock") public var createUserBlock
    @Field<UserHide>("createUserHide") public var createUserHide
    @Field<Bool>("purchase") public var purchase
    @Field<User>("updateUserProfile") public var updateUserProfile
    @Field<User>("updateUsername") public var updateUsername
  }
}

public extension Mock where O == Mutation {
  convenience init(
    approveFriendRequest: Mock<Friend>? = nil,
    createFirebaseRegistrationToken: Mock<FirebaseRegistrationToken>? = nil,
    createFriendRequest: Mock<Friend>? = nil,
    createUser: Mock<User>? = nil,
    createUserBlock: Mock<UserBlock>? = nil,
    createUserHide: Mock<UserHide>? = nil,
    purchase: Bool? = nil,
    updateUserProfile: Mock<User>? = nil,
    updateUsername: Mock<User>? = nil
  ) {
    self.init()
    _setEntity(approveFriendRequest, for: \.approveFriendRequest)
    _setEntity(createFirebaseRegistrationToken, for: \.createFirebaseRegistrationToken)
    _setEntity(createFriendRequest, for: \.createFriendRequest)
    _setEntity(createUser, for: \.createUser)
    _setEntity(createUserBlock, for: \.createUserBlock)
    _setEntity(createUserHide, for: \.createUserHide)
    _setScalar(purchase, for: \.purchase)
    _setEntity(updateUserProfile, for: \.updateUserProfile)
    _setEntity(updateUsername, for: \.updateUsername)
  }
}
