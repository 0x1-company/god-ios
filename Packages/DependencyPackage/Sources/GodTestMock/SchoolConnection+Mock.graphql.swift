// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class SchoolConnection: MockObject {
  public static let objectType: Object = God.Objects.SchoolConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<SchoolConnection>>

  public struct MockFields {
    @Field<[SchoolEdge]>("edges") public var edges
  }
}

public extension Mock where O == SchoolConnection {
  convenience init(
    edges: [Mock<SchoolEdge>]? = nil
  ) {
    self.init()
    _setList(edges, for: \.edges)
  }
}
