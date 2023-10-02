// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class InboxActivity: MockObject {
  public static let objectType: Object = God.Objects.InboxActivity
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<InboxActivity>>

  public struct MockFields {
    @Field<God.Date>("createdAt") public var createdAt
    @Field<God.ID>("id") public var id
    @Field<String>("initial") public var initial
    @Field<Bool>("isRead") public var isRead
    @Field<Question>("question") public var question
    @Field<PublicVoteUser>("voteUser") public var voteUser
  }
}

public extension Mock where O == InboxActivity {
  convenience init(
    createdAt: God.Date? = nil,
    id: God.ID? = nil,
    initial: String? = nil,
    isRead: Bool? = nil,
    question: Mock<Question>? = nil,
    voteUser: Mock<PublicVoteUser>? = nil
  ) {
    self.init()
    _setScalar(createdAt, for: \.createdAt)
    _setScalar(id, for: \.id)
    _setScalar(initial, for: \.initial)
    _setScalar(isRead, for: \.isRead)
    _setEntity(question, for: \.question)
    _setEntity(voteUser, for: \.voteUser)
  }
}
