// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class Query: MockObject {
  public static let objectType: Object = God.Objects.Query
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Query>>

  public struct MockFields {
    @Field<Store>("store") public var store
    @Field<User>("user") public var user
  }
}

public extension Mock where O == Query {
  convenience init(
    store: Mock<Store>? = nil,
    user: Mock<User>? = nil
  ) {
    self.init()
    _setEntity(store, for: \.store)
    _setEntity(user, for: \.user)
  }
}
