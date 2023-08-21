// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class LocalizableString: MockObject {
  public static let objectType: Object = God.Objects.LocalizableString
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<LocalizableString>>

  public struct MockFields {
    @Field<String>("ja") public var ja
  }
}

public extension Mock where O == LocalizableString {
  convenience init(
    ja: String? = nil
  ) {
    self.init()
    _setScalar(ja, for: \.ja)
  }
}
