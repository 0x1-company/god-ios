// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class InboxActivityEdge: MockObject {
  public static let objectType: Object = God.Objects.InboxActivityEdge
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<InboxActivityEdge>>

  public struct MockFields {
    @Field<String>("cursor") public var cursor
    @Field<InboxActivity>("node") public var node
  }
}

public extension Mock where O == InboxActivityEdge {
  convenience init(
    cursor: String? = nil,
    node: Mock<InboxActivity>? = nil
  ) {
    self.init()
    _setScalar(cursor, for: \.cursor)
    _setEntity(node, for: \.node)
  }
}
