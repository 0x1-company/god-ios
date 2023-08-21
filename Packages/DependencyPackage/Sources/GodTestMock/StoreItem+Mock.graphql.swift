// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class StoreItem: MockObject {
  public static let objectType: Object = God.Objects.StoreItem
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<StoreItem>>

  public struct MockFields {
    @Field<Int>("coinAmount") public var coinAmount
    @Field<God.ID>("id") public var id
    @Field<Item>("item") public var item
    @Field<String>("itemId") public var itemId
    @Field<GraphQLEnum<God.StoreItemStatus>>("status") public var status
  }
}

public extension Mock where O == StoreItem {
  convenience init(
    coinAmount: Int? = nil,
    id: God.ID? = nil,
    item: Mock<Item>? = nil,
    itemId: String? = nil,
    status: GraphQLEnum<God.StoreItemStatus>? = nil
  ) {
    self.init()
    _setScalar(coinAmount, for: \.coinAmount)
    _setScalar(id, for: \.id)
    _setEntity(item, for: \.item)
    _setScalar(itemId, for: \.itemId)
    _setScalar(status, for: \.status)
  }
}
