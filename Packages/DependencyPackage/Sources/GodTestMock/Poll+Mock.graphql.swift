// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class Poll: MockObject {
  public static let objectType: Object = God.Objects.Poll
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Poll>>

  public struct MockFields {
    @Field<God.ID>("id") public var id
    @Field<[PollQuestion]>("pollQuestions") public var pollQuestions
  }
}

public extension Mock where O == Poll {
  convenience init(
    id: God.ID? = nil,
    pollQuestions: [Mock<PollQuestion>]? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
    _setList(pollQuestions, for: \.pollQuestions)
  }
}
