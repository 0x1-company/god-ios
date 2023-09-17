// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class UserEdge: MockObject {
  public static let objectType: Object = God.Objects.UserEdge
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<UserEdge>>

  public struct MockFields {
    @Field<String>("cursor") public var cursor
    @Field<User>("node") public var node
  }
}

public extension Mock where O == UserEdge {
  convenience init(
    cursor: String? = nil,
    node: Mock<User>? = nil
  ) {
    self.init()
    _setScalar(cursor, for: \.cursor)
    _setEntity(node, for: \.node)
  }
}
