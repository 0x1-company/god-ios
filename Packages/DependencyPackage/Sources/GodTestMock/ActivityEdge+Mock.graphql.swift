// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class ActivityEdge: MockObject {
  public static let objectType: Object = God.Objects.ActivityEdge
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<ActivityEdge>>

  public struct MockFields {
    @Field<String>("cursor") public var cursor
    @Field<Activity>("node") public var node
  }
}

public extension Mock where O == ActivityEdge {
  convenience init(
    cursor: String? = nil,
    node: Mock<Activity>? = nil
  ) {
    self.init()
    _setScalar(cursor, for: \.cursor)
    _setEntity(node, for: \.node)
  }
}
