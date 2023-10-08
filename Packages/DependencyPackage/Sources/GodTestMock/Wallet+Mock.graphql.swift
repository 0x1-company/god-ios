// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class Wallet: MockObject {
  public static let objectType: Object = God.Objects.Wallet
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Wallet>>

  public struct MockFields {
    @Field<Int>("coinBalance") public var coinBalance
    @Field<God.ID>("id") public var id
  }
}

public extension Mock where O == Wallet {
  convenience init(
    coinBalance: Int? = nil,
    id: God.ID? = nil
  ) {
    self.init()
    _setScalar(coinBalance, for: \.coinBalance)
    _setScalar(id, for: \.id)
  }
}
