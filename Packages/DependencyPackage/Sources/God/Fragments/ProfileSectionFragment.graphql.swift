// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  struct ProfileSectionFragment: God.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ProfileSectionFragment on User { __typename id firstName lastName username generation friendsCount schoolId school { __typename id name shortName } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", God.ID.self),
      .field("firstName", String.self),
      .field("lastName", String.self),
      .field("username", String?.self),
      .field("generation", Int?.self),
      .field("friendsCount", Int?.self),
      .field("schoolId", String?.self),
      .field("school", School?.self),
    ] }

    /// user id
    public var id: God.ID { __data["id"] }
    /// first name
    public var firstName: String { __data["firstName"] }
    /// last name
    public var lastName: String { __data["lastName"] }
    /// username
    public var username: String? { __data["username"] }
    /// 年代
    public var generation: Int? { __data["generation"] }
    /// friends count
    public var friendsCount: Int? { __data["friendsCount"] }
    public var schoolId: String? { __data["schoolId"] }
    /// school to which the user belongs
    public var school: School? { __data["school"] }

    /// School
    ///
    /// Parent Type: `School`
    public struct School: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.School }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", God.ID.self),
        .field("name", String.self),
        .field("shortName", String.self),
      ] }

      public var id: God.ID { __data["id"] }
      /// 学校名
      public var name: String { __data["name"] }
      /// 学校名（略称）
      public var shortName: String { __data["shortName"] }
    }
  }

}