// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class School: MockObject {
  public static let objectType: Object = God.Objects.School
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<School>>

  public struct MockFields {
    @Field<God.ID>("id") public var id
    @Field<String>("name") public var name
    @Field<String>("shortName") public var shortName
    @Field<Int>("usersCount") public var usersCount
  }
}

public extension Mock where O == School {
  convenience init(
    id: God.ID? = nil,
    name: String? = nil,
    shortName: String? = nil,
    usersCount: Int? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
    _setScalar(name, for: \.name)
    _setScalar(shortName, for: \.shortName)
    _setScalar(usersCount, for: \.usersCount)
  }
}
