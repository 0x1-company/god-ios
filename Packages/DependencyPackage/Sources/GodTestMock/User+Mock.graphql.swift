// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class User: MockObject {
  public static let objectType: Object = God.Objects.User
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<User>>

  public struct MockFields {
    @Field<String>("firstName") public var firstName
    @Field<GraphQLEnum<God.Gender>>("gender") public var gender
    @Field<God.ID>("id") public var id
    @Field<String>("lastName") public var lastName
    @Field<School>("school") public var school
    @Field<String>("schoolId") public var schoolId
    @Field<String>("username") public var username
  }
}

public extension Mock where O == User {
  convenience init(
    firstName: String? = nil,
    gender: GraphQLEnum<God.Gender>? = nil,
    id: God.ID? = nil,
    lastName: String? = nil,
    school: Mock<School>? = nil,
    schoolId: String? = nil,
    username: String? = nil
  ) {
    self.init()
    _setScalar(firstName, for: \.firstName)
    _setScalar(gender, for: \.gender)
    _setScalar(id, for: \.id)
    _setScalar(lastName, for: \.lastName)
    _setEntity(school, for: \.school)
    _setScalar(schoolId, for: \.schoolId)
    _setScalar(username, for: \.username)
  }
}
