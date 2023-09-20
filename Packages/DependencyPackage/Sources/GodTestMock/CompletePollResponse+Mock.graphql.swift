// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class CompletePollResponse: MockObject {
  public static let objectType: Object = God.Objects.CompletePollResponse
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CompletePollResponse>>

  public struct MockFields {
    @Field<Int>("earnedCoinAmount") public var earnedCoinAmount
  }
}

public extension Mock where O == CompletePollResponse {
  convenience init(
    earnedCoinAmount: Int? = nil
  ) {
    self.init()
    _setScalar(earnedCoinAmount, for: \.earnedCoinAmount)
  }
}
