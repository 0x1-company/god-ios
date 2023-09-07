// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class PageInfo: MockObject {
  public static let objectType: Object = God.Objects.PageInfo
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<PageInfo>>

  public struct MockFields {
    @Field<String>("endCursor") public var endCursor
    @Field<Bool>("hasNextPage") public var hasNextPage
  }
}

public extension Mock where O == PageInfo {
  convenience init(
    endCursor: String? = nil,
    hasNextPage: Bool? = nil
  ) {
    self.init()
    _setScalar(endCursor, for: \.endCursor)
    _setScalar(hasNextPage, for: \.hasNextPage)
  }
}
