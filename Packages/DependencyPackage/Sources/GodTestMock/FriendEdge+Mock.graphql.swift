// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class FriendEdge: MockObject {
  public static let objectType: Object = God.Objects.FriendEdge
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<FriendEdge>>

  public struct MockFields {
    @Field<Friend>("node") public var node
  }
}

public extension Mock where O == FriendEdge {
  convenience init(
    node: Mock<Friend>? = nil
  ) {
    self.init()
    _setEntity(node, for: \.node)
  }
}
