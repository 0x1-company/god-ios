// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class Question: MockObject {
  public static let objectType: Object = God.Objects.Question
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Question>>

  public struct MockFields {
    @Field<God.ID>("id") public var id
    @Field<LocalizableString>("text") public var text
  }
}

public extension Mock where O == Question {
  convenience init(
    id: God.ID? = nil,
    text: Mock<LocalizableString>? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
    _setEntity(text, for: \.text)
  }
}
