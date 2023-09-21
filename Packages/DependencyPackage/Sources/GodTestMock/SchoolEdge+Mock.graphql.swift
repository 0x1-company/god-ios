// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class SchoolEdge: MockObject {
  public static let objectType: Object = God.Objects.SchoolEdge
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<SchoolEdge>>

  public struct MockFields {
    @Field<School>("node") public var node
  }
}

public extension Mock where O == SchoolEdge {
  convenience init(
    node: Mock<School>? = nil
  ) {
    self.init()
    _setEntity(node, for: \.node)
  }
}
