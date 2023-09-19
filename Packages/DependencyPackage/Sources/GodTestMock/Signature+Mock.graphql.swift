// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class Signature: MockObject {
  public static let objectType: Object = God.Objects.Signature
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Signature>>

  public struct MockFields {
    @Field<String>("digest") public var digest
  }
}

public extension Mock where O == Signature {
  convenience init(
    digest: String? = nil
  ) {
    self.init()
    _setScalar(digest, for: \.digest)
  }
}
