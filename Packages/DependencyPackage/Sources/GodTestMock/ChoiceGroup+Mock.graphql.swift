// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class ChoiceGroup: MockObject {
  public static let objectType: Object = God.Objects.ChoiceGroup
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<ChoiceGroup>>

  public struct MockFields {
    @Field<[Choice]>("choices") public var choices
    @Field<Signature>("signature") public var signature
  }
}

public extension Mock where O == ChoiceGroup {
  convenience init(
    choices: [Mock<Choice>]? = nil,
    signature: Mock<Signature>? = nil
  ) {
    self.init()
    _setList(choices, for: \.choices)
    _setEntity(signature, for: \.signature)
  }
}
