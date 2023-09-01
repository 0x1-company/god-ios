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
    @Field<LocalizableString>("description") public var description
    @Field<God.ID>("id") public var id
    @Field<GraphQLEnum<God.ItemType>>("itemType") public var itemType
    @Field<Int>("quantity") public var quantity
    @Field<GraphQLEnum<God.StoreItemStatus>>("status") public var status
    @Field<LocalizableString>("title") public var title
  }
}

public extension Mock where O == StoreItem {
  convenience init(
    coinAmount: Int? = nil,
    description: Mock<LocalizableString>? = nil,
    id: God.ID? = nil,
    itemType: GraphQLEnum<God.ItemType>? = nil,
    quantity: Int? = nil,
    status: GraphQLEnum<God.StoreItemStatus>? = nil,
    title: Mock<LocalizableString>? = nil
  ) {
    self.init()
    _setScalar(coinAmount, for: \.coinAmount)
    _setEntity(description, for: \.description)
    _setScalar(id, for: \.id)
    _setScalar(itemType, for: \.itemType)
    _setScalar(quantity, for: \.quantity)
    _setScalar(status, for: \.status)
    _setEntity(title, for: \.title)
  }
}
