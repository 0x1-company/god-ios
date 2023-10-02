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
  }
}

public extension Mock where O == PublicVoteUser {
  convenience init(
    gender: GraphQLEnum<God.Gender>? = nil,
    grade: String? = nil
  ) {
    self.init()
    _setScalar(gender, for: \.gender)
    _setScalar(grade, for: \.grade)
  }
}
