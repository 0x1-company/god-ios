// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class CurrentPoll: MockObject {
  public static let objectType: Object = God.Objects.CurrentPoll
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CurrentPoll>>

  public struct MockFields {
    @Field<CoolDown>("coolDown") public var coolDown
    @Field<Poll>("poll") public var poll
    @Field<GraphQLEnum<God.CurrentPollStatus>>("status") public var status
  }
}

public extension Mock where O == CurrentPoll {
  convenience init(
    coolDown: Mock<CoolDown>? = nil,
    poll: Mock<Poll>? = nil,
    status: GraphQLEnum<God.CurrentPollStatus>? = nil
  ) {
    self.init()
    _setEntity(coolDown, for: \.coolDown)
    _setEntity(poll, for: \.poll)
    _setScalar(status, for: \.status)
  }
}
