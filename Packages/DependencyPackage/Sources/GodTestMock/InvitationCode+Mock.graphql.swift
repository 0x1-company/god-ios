// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class InvitationCode: MockObject {
  public static let objectType: Object = God.Objects.InvitationCode
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<InvitationCode>>

  public struct MockFields {
    @Field<String>("code") public var code
    @Field<God.ID>("id") public var id
  }
}

public extension Mock where O == InvitationCode {
  convenience init(
    code: String? = nil,
    id: God.ID? = nil
  ) {
    self.init()
    _setScalar(code, for: \.code)
    _setScalar(id, for: \.id)
  }
}
