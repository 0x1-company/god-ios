// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class Query: MockObject {
  public static let objectType: Object = God.Objects.Query
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Query>>

  public struct MockFields {
    @Field<User>("user") public var user
  }
}

public extension Mock where O == Query {
  convenience init(
    user: Mock<User>? = nil
  ) {
    self.init()
    _setEntity(user, for: \.user)
  }
}
