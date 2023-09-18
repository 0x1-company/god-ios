// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class FirebaseRegistrationToken: MockObject {
  public static let objectType: Object = God.Objects.FirebaseRegistrationToken
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<FirebaseRegistrationToken>>

  public struct MockFields {
    @Field<String>("token") public var token
  }
}

public extension Mock where O == FirebaseRegistrationToken {
  convenience init(
    token: String? = nil
  ) {
    self.init()
    _setScalar(token, for: \.token)
  }
}
