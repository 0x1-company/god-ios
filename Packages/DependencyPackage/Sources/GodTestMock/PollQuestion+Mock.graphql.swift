// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class PollQuestion: MockObject {
  public static let objectType: Object = God.Objects.PollQuestion
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<PollQuestion>>

  public struct MockFields {
    @Field<[ChoiceGroup]>("choiceGroups") public var choiceGroups
    @Field<God.ID>("id") public var id
    @Field<Question>("question") public var question
  }
}

public extension Mock where O == PollQuestion {
  convenience init(
    choiceGroups: [Mock<ChoiceGroup>]? = nil,
    id: God.ID? = nil,
    question: Mock<Question>? = nil
  ) {
    self.init()
    _setList(choiceGroups, for: \.choiceGroups)
    _setScalar(id, for: \.id)
    _setEntity(question, for: \.question)
  }
}
