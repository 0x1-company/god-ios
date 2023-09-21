// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class Subscription: MockObject {
  public static let objectType: Object = God.Objects.Subscription
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Subscription>>

  public struct MockFields {
    @Field<God.Date>("expireAt") public var expireAt
    @Field<God.ID>("id") public var id
    @Field<String>("productId") public var productId
    @Field<String>("transactionId") public var transactionId
  }
}

public extension Mock where O == Subscription {
  convenience init(
    expireAt: God.Date? = nil,
    id: God.ID? = nil,
    productId: String? = nil,
    transactionId: String? = nil
  ) {
    self.init()
    _setScalar(expireAt, for: \.expireAt)
    _setScalar(id, for: \.id)
    _setScalar(productId, for: \.productId)
    _setScalar(transactionId, for: \.transactionId)
  }
}
