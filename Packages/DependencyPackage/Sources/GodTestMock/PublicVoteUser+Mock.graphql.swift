// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class PublicVoteUser: MockObject {
  public static let objectType: Object = God.Objects.PublicVoteUser
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<PublicVoteUser>>

  public struct MockFields {
    @Field<GraphQLEnum<God.Gender>>("gender") public var gender
    @Field<String>("grade") public var grade
    @Field<God.ID>("id") public var id
  }
}

public extension Mock where O == PublicVoteUser {
  convenience init(
    gender: GraphQLEnum<God.Gender>? = nil,
    grade: String? = nil,
    id: God.ID? = nil
  ) {
    self.init()
    _setScalar(gender, for: \.gender)
    _setScalar(grade, for: \.grade)
    _setScalar(id, for: \.id)
  }
}
