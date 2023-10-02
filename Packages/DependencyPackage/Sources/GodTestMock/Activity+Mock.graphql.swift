// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class Activity: MockObject {
  public static let objectType: Object = God.Objects.Activity
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Activity>>

  public struct MockFields {
    @Field<God.Date>("createdAt") public var createdAt
    @Field<God.ID>("id") public var id
    @Field<Question>("question") public var question
    @Field<User>("user") public var user
    @Field<String>("userId") public var userId
    @Field<PublicVoteUser>("voteUser") public var voteUser
  }
}

public extension Mock where O == Activity {
  convenience init(
    createdAt: God.Date? = nil,
    id: God.ID? = nil,
    question: Mock<Question>? = nil,
    user: Mock<User>? = nil,
    userId: String? = nil,
    voteUser: Mock<PublicVoteUser>? = nil
  ) {
    self.init()
    _setScalar(createdAt, for: \.createdAt)
    _setScalar(id, for: \.id)
    _setEntity(question, for: \.question)
    _setEntity(user, for: \.user)
    _setScalar(userId, for: \.userId)
    _setEntity(voteUser, for: \.voteUser)
  }
}
