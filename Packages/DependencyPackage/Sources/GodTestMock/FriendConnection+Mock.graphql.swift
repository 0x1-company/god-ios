// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class FriendConnection: MockObject {
  public static let objectType: Object = God.Objects.FriendConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<FriendConnection>>

  public struct MockFields {
    @Field<[FriendEdge]>("edges") public var edges
  }
}

public extension Mock where O == FriendConnection {
  convenience init(
    edges: [Mock<FriendEdge>]? = nil
  ) {
    self.init()
    _setList(edges, for: \.edges)
  }
}
