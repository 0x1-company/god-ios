// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class Item: MockObject {
  public static let objectType: Object = God.Objects.Item
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Item>>

  public struct MockFields {
    @Field<LocalizableString>("title") public var title
  }
}

public extension Mock where O == Item {
  convenience init(
    title: Mock<LocalizableString>? = nil
  ) {
    self.init()
    _setEntity(title, for: \.title)
  }
}
