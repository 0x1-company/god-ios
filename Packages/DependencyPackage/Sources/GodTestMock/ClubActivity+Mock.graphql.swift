// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class ClubActivity: MockObject {
  public static let objectType: Object = God.Objects.ClubActivity
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<ClubActivity>>

  public struct MockFields {
    @Field<God.ID>("id") public var id
    @Field<String>("name") public var name
    @Field<Int>("position") public var position
  }
}

public extension Mock where O == ClubActivity {
  convenience init(
    id: God.ID? = nil,
    name: String? = nil,
    position: Int? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
    _setScalar(name, for: \.name)
    _setScalar(position, for: \.position)
  }
}
