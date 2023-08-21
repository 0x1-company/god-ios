// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class UserHide: MockObject {
  public static let objectType: Object = God.Objects.UserHide
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<UserHide>>

  public struct MockFields {
    @Field<String>("hiddenUserId") public var hiddenUserId
    @Field<God.ID>("id") public var id
    @Field<String>("userId") public var userId
  }
}

public extension Mock where O == UserHide {
  convenience init(
    hiddenUserId: String? = nil,
    id: God.ID? = nil,
    userId: String? = nil
  ) {
    self.init()
    _setScalar(hiddenUserId, for: \.hiddenUserId)
    _setScalar(id, for: \.id)
    _setScalar(userId, for: \.userId)
  }
}
