// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import God

public class Banner: MockObject {
  public static let objectType: Object = God.Objects.Banner
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Banner>>

  public struct MockFields {
    @Field<String>("description") public var description
    @Field<God.Date>("endAt") public var endAt
    @Field<God.ID>("id") public var id
    @Field<God.Date>("startAt") public var startAt
    @Field<String>("title") public var title
    @Field<String>("url") public var url
  }
}

public extension Mock where O == Banner {
  convenience init(
    description: String? = nil,
    endAt: God.Date? = nil,
    id: God.ID? = nil,
    startAt: God.Date? = nil,
    title: String? = nil,
    url: String? = nil
  ) {
    self.init()
    _setScalar(description, for: \.description)
    _setScalar(endAt, for: \.endAt)
    _setScalar(id, for: \.id)
    _setScalar(startAt, for: \.startAt)
    _setScalar(title, for: \.title)
    _setScalar(url, for: \.url)
  }
}
