// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class CoolDown: MockObject {
  public static let objectType: Object = God.Objects.CoolDown
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CoolDown>>

  public struct MockFields {
    @Field<God.Date>("until") public var until
  }
}

public extension Mock where O == CoolDown {
  convenience init(
    until: God.Date? = nil
  ) {
    self.init()
    _setScalar(until, for: \.until)
  }
}
