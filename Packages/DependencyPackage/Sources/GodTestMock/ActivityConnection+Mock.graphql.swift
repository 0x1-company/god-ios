// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class ActivityConnection: MockObject {
  public static let objectType: Object = God.Objects.ActivityConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<ActivityConnection>>

  public struct MockFields {
    @Field<[ActivityEdge]>("edges") public var edges
    @Field<PageInfo>("pageInfo") public var pageInfo
  }
}

public extension Mock where O == ActivityConnection {
  convenience init(
    edges: [Mock<ActivityEdge>]? = nil,
    pageInfo: Mock<PageInfo>? = nil
  ) {
    self.init()
    _setList(edges, for: \.edges)
    _setEntity(pageInfo, for: \.pageInfo)
  }
}
