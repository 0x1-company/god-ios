// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  struct ProfileStoryFragment: God.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ProfileStoryFragment on User { __typename id imageURL firstName username displayName { __typename ja } school { __typename id name profileImageURL } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", God.ID.self),
      .field("imageURL", String.self),
      .field("firstName", String.self),
      .field("username", String?.self),
      .field("displayName", DisplayName.self),
      .field("school", School?.self),
    ] }

    /// user id
    public var id: God.ID { __data["id"] }
    /// プロフィール画像のURL
    public var imageURL: String { __data["imageURL"] }
    /// first name
    public var firstName: String { __data["firstName"] }
    /// username
    public var username: String? { __data["username"] }
    /// 表示名
    public var displayName: DisplayName { __data["displayName"] }
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
        .field("profileImageURL", String.self),
      ] }

      public var id: God.ID { __data["id"] }
      /// 学校名
      public var name: String { __data["name"] }
      /// アイコン画像URL
      public var profileImageURL: String { __data["profileImageURL"] }
    }
  }

}