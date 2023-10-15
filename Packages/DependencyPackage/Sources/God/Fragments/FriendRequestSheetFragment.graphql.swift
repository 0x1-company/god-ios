// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  struct FriendRequestSheetFragment: God.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment FriendRequestSheetFragment on Friend { __typename id user { __typename id imageURL firstName displayName { __typename ja } votedCount username school { __typename id shortName } grade } }"#
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
        .field("id", God.ID.self),
        .field("imageURL", String.self),
        .field("firstName", String.self),
        .field("displayName", DisplayName.self),
        .field("votedCount", Int.self),
        .field("username", String?.self),
        .field("school", School?.self),
        .field("grade", String?.self),
      ] }

      /// user id
      public var id: God.ID { __data["id"] }
      /// プロフィール画像のURL
      public var imageURL: String { __data["imageURL"] }
      /// first name
      public var firstName: String { __data["firstName"] }
      /// 表示名
      public var displayName: DisplayName { __data["displayName"] }
      /// 投票された数
      public var votedCount: Int { __data["votedCount"] }
      /// username
      public var username: String? { __data["username"] }
      /// 所属している学校
      public var school: School? { __data["school"] }
      /// 学年をテキストで返す
      public var grade: String? { __data["grade"] }

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

      /// User.School
      ///
      /// Parent Type: `School`
      public struct School: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.School }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", God.ID.self),
          .field("shortName", String.self),
        ] }

        public var id: God.ID { __data["id"] }
        /// 学校名（略称）
        public var shortName: String { __data["shortName"] }
      }
    }
  }

}