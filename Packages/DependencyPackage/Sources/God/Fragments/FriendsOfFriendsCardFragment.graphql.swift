// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  struct FriendsOfFriendsCardFragment: God.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment FriendsOfFriendsCardFragment on User { __typename id mutualFriendsCount imageURL displayName { __typename ja } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", God.ID.self),
      .field("mutualFriendsCount", Int.self),
      .field("imageURL", String.self),
      .field("displayName", DisplayName.self),
    ] }

    /// user id
    public var id: God.ID { __data["id"] }
    /// 共通のフレンド数
    public var mutualFriendsCount: Int { __data["mutualFriendsCount"] }
    /// プロフィール画像のURL
    public var imageURL: String { __data["imageURL"] }
    /// 表示名
    public var displayName: DisplayName { __data["displayName"] }

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
  }

}