// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class VoteChoice: MockObject {
  public static let objectType: Object = God.Objects.VoteChoice
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<VoteChoice>>

  public struct MockFields {
    @Field<String>("id") public var id
    @Field<Int>("orderIndex") public var orderIndex
    @Field<String>("text") public var text
    @Field<String>("userId") public var userId
  }
}

public extension Mock where O == VoteChoice {
  convenience init(
    id: String? = nil,
    orderIndex: Int? = nil,
    text: String? = nil,
    userId: String? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
    _setScalar(orderIndex, for: \.orderIndex)
    _setScalar(text, for: \.text)
    _setScalar(userId, for: \.userId)
  }
}
