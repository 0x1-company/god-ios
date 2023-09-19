// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class Choice: MockObject {
  public static let objectType: Object = God.Objects.Choice
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Choice>>

  public struct MockFields {
    @Field<String>("text") public var text
    @Field<God.ID>("userId") public var userId
  }
}

public extension Mock where O == Choice {
  convenience init(
    text: String? = nil,
    userId: God.ID? = nil
  ) {
    self.init()
    _setScalar(text, for: \.text)
    _setScalar(userId, for: \.userId)
  }
}
