// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class InboxActivityConnection: MockObject {
  public static let objectType: Object = God.Objects.InboxActivityConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<InboxActivityConnection>>

  public struct MockFields {
    @Field<[InboxActivityEdge]>("edges") public var edges
    @Field<PageInfo>("pageInfo") public var pageInfo
  }
}

public extension Mock where O == InboxActivityConnection {
  convenience init(
    edges: [Mock<InboxActivityEdge>]? = nil,
    pageInfo: Mock<PageInfo>? = nil
  ) {
    self.init()
    _setList(edges, for: \.edges)
    _setEntity(pageInfo, for: \.pageInfo)
  }
}
