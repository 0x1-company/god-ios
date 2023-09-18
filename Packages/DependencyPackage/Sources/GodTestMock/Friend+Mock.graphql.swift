// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class Friend: MockObject {
  public static let objectType: Object = God.Objects.Friend
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Friend>>

  public struct MockFields {
    @Field<String>("friendUserId") public var friendUserId
    @Field<God.ID>("id") public var id
    @Field<GraphQLEnum<God.FriendStatus>>("status") public var status
    @Field<User>("user") public var user
    @Field<String>("userId") public var userId
  }
}

public extension Mock where O == Friend {
  convenience init(
    friendUserId: String? = nil,
    id: God.ID? = nil,
    status: GraphQLEnum<God.FriendStatus>? = nil,
    user: Mock<User>? = nil,
    userId: String? = nil
  ) {
    self.init()
    _setScalar(friendUserId, for: \.friendUserId)
    _setScalar(id, for: \.id)
    _setScalar(status, for: \.status)
    _setEntity(user, for: \.user)
    _setScalar(userId, for: \.userId)
  }
}
