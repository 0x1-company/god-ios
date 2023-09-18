// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  struct FriendRequestCardFragment: God.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment FriendRequestCardFragment on Friend { __typename id user { __typename displayName { __typename ja } mutualFriendsCount } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { God.Objects.Friend }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", God.ID.self),
      .field("user", User.self),
    ] }

    public var id: God.ID { __data["id"] }
    /// ユーザー情報
    public var user: User { __data["user"] }

    /// User
    ///
    /// Parent Type: `User`
    public struct User: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("displayName", DisplayName.self),
        .field("mutualFriendsCount", Int.self),
      ] }

      /// 表示名
      public var displayName: DisplayName { __data["displayName"] }
      /// 共通のフレンド数
      public var mutualFriendsCount: Int { __data["mutualFriendsCount"] }

      /// User.DisplayName
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

}