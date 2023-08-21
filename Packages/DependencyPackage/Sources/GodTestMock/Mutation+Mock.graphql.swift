// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class Mutation: MockObject {
  public static let objectType: Object = God.Objects.Mutation
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = [Mock<Mutation>]

  public struct MockFields {
    @Field<User>("updateUsername") public var updateUsername
  }
}

public extension Mock where O == Mutation {
  convenience init(
    updateUsername: Mock<User>? = nil
  ) {
    self.init()
    _setEntity(updateUsername, for: \.updateUsername)
  }
}
