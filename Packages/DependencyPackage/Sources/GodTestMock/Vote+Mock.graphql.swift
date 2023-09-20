// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class Vote: MockObject {
  public static let objectType: Object = God.Objects.Vote
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Vote>>

  public struct MockFields {
    @Field<God.ID>("id") public var id
  }
}

public extension Mock where O == Vote {
  convenience init(
    id: God.ID? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
  }
}
