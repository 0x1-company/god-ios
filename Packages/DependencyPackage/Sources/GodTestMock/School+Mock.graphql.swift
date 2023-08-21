// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class School: MockObject {
  public static let objectType: Object = God.Objects.School
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = [Mock<School>]

  public struct MockFields {
    @Field<God.ID>("id") public var id
    @Field<String>("name") public var name
    @Field<String>("shortName") public var shortName
  }
}

public extension Mock where O == School {
  convenience init(
    id: God.ID? = nil,
    name: String? = nil,
    shortName: String? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
    _setScalar(name, for: \.name)
    _setScalar(shortName, for: \.shortName)
  }
}
