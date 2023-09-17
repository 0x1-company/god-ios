// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class UserConnection: MockObject {
  public static let objectType: Object = God.Objects.UserConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<UserConnection>>

  public struct MockFields {
    @Field<[UserEdge]>("edges") public var edges
    @Field<PageInfo>("pageInfo") public var pageInfo
  }
}

public extension Mock where O == UserConnection {
  convenience init(
    edges: [Mock<UserEdge>]? = nil,
    pageInfo: Mock<PageInfo>? = nil
  ) {
    self.init()
    _setList(edges, for: \.edges)
    _setEntity(pageInfo, for: \.pageInfo)
  }
}
