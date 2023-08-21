// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class UserBlock: MockObject {
  public static let objectType: Object = God.Objects.UserBlock
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = [Mock<UserBlock>]

  public struct MockFields {
    @Field<String>("blockedUserId") public var blockedUserId
    @Field<God.ID>("id") public var id
    @Field<String>("userId") public var userId
  }
}

public extension Mock where O == UserBlock {
  convenience init(
    blockedUserId: String? = nil,
    id: God.ID? = nil,
    userId: String? = nil
  ) {
    self.init()
    _setScalar(blockedUserId, for: \.blockedUserId)
    _setScalar(id, for: \.id)
    _setScalar(userId, for: \.userId)
  }
}
