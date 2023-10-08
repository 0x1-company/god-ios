// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  struct FriendRequestCardFragment: God.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment FriendRequestCardFragment on Friend { __typename id status user { __typename id imageURL friendStatus mutualFriendsCount displayName { __typename ja } firstName lastName } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { God.Objects.Friend }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", God.ID.self),
      .field("status", GraphQLEnum<God.FriendStatus>.self),
      .field("user", User.self),
    ] }

    public var id: God.ID { __data["id"] }
    /// フレンド状態
    public var status: GraphQLEnum<God.FriendStatus> { __data["status"] }
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
        .field("id", God.ID.self),
        .field("imageURL", String.self),
        .field("friendStatus", GraphQLEnum<God.FriendStatus>.self),
        .field("mutualFriendsCount", Int.self),
        .field("displayName", DisplayName.self),
        .field("firstName", String.self),
        .field("lastName", String.self),
      ] }

      /// user id
      public var id: God.ID { __data["id"] }
      /// プロフィール画像のURL
      public var imageURL: String { __data["imageURL"] }
      /// フレンドステータス
      public var friendStatus: GraphQLEnum<God.FriendStatus> { __data["friendStatus"] }
      /// 共通のフレンド数
      public var mutualFriendsCount: Int { __data["mutualFriendsCount"] }
      /// 表示名
      public var displayName: DisplayName { __data["displayName"] }
      /// first name
      public var firstName: String { __data["firstName"] }
      /// last name
      public var lastName: String { __data["lastName"] }

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