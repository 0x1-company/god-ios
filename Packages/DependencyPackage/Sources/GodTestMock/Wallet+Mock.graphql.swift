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
  }
}

public extension Mock where O == Wallet {
  convenience init(
    coinBalance: Int? = nil
  ) {
    self.init()
    _setScalar(coinBalance, for: \.coinBalance)
  }
}
