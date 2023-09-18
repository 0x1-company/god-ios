// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  struct ProfileSectionFragment: God.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ProfileSectionFragment on User { __typename id displayName { __typename ja } username generation friendsCount schoolId grade school { __typename id name shortName } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", God.ID.self),
      .field("displayName", DisplayName.self),
      .field("username", String?.self),
      .field("generation", Int?.self),
      .field("friendsCount", Int?.self),
      .field("schoolId", String?.self),
      .field("grade", String?.self),
      .field("school", School?.self),
    ] }

    /// user id
    public var id: God.ID { __data["id"] }
    /// 表示名
    public var displayName: DisplayName { __data["displayName"] }
    /// username
    public var username: String? { __data["username"] }
    /// 年代
    public var generation: Int? { __data["generation"] }
    /// フレンド数
    public var friendsCount: Int? { __data["friendsCount"] }
    public var schoolId: String? { __data["schoolId"] }
    /// 学年をテキストで返す
    public var grade: String? { __data["grade"] }
    /// 所属している学校
    public var school: School? { __data["school"] }

    /// DisplayName
    ///
    /// Parent Type: `LocalizableString`
    public struct DisplayName: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.LocalizableString }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("ja", String.self),
      ] }

      /// 日本語
      public var ja: String { __data["ja"] }
    }

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