// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class Store: MockObject {
  public static let objectType: Object = God.Objects.Store
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Store>>

  public struct MockFields {
    @Field<[StoreItem]>("items") public var items
  }
}

public extension Mock where O == Store {
  convenience init(
    items: [Mock<StoreItem>]? = nil
  ) {
    self.init()
    _setList(items, for: \.items)
  }
}
