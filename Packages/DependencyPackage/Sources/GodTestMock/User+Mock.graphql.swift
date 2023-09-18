// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class User: MockObject {
  public static let objectType: Object = God.Objects.User
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<User>>

  public struct MockFields {
    @Field<LocalizableString>("displayName") public var displayName
    @Field<String>("firstName") public var firstName
    @Field<Int>("friendsCount") public var friendsCount
    @Field<GraphQLEnum<God.Gender>>("gender") public var gender
    @Field<Int>("generation") public var generation
    @Field<String>("grade") public var grade
    @Field<God.ID>("id") public var id
    @Field<String>("lastName") public var lastName
    @Field<Int>("mutualFriendsCount") public var mutualFriendsCount
    @Field<School>("school") public var school
    @Field<String>("schoolId") public var schoolId
    @Field<String>("username") public var username
    @Field<Wallet>("wallet") public var wallet
  }
}

public extension Mock where O == User {
  convenience init(
    displayName: Mock<LocalizableString>? = nil,
    firstName: String? = nil,
    friendsCount: Int? = nil,
    gender: GraphQLEnum<God.Gender>? = nil,
    generation: Int? = nil,
    grade: String? = nil,
    id: God.ID? = nil,
    lastName: String? = nil,
    mutualFriendsCount: Int? = nil,
    school: Mock<School>? = nil,
    schoolId: String? = nil,
    username: String? = nil,
    wallet: Mock<Wallet>? = nil
  ) {
    self.init()
    _setEntity(displayName, for: \.displayName)
    _setScalar(firstName, for: \.firstName)
    _setScalar(friendsCount, for: \.friendsCount)
    _setScalar(gender, for: \.gender)
    _setScalar(generation, for: \.generation)
    _setScalar(grade, for: \.grade)
    _setScalar(id, for: \.id)
    _setScalar(lastName, for: \.lastName)
    _setScalar(mutualFriendsCount, for: \.mutualFriendsCount)
    _setEntity(school, for: \.school)
    _setScalar(schoolId, for: \.schoolId)
    _setScalar(username, for: \.username)
    _setEntity(wallet, for: \.wallet)
  }
}
