// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class UserSearchQuery: GraphQLQuery {
    public static let operationName: String = "UserSearch"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query UserSearch($username: String!) { userSearch(username: $username) { __typename id firstName lastName displayName { __typename ja } username imageURL friendStatus mutualFriendsCount } }"#
      ))

    public var username: String

    public init(username: String) {
      self.username = username
    }

    public var __variables: Variables? { ["username": username] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("userSearch", UserSearch.self, arguments: ["username": .variable("username")]),
      ] }

      public var userSearch: UserSearch { __data["userSearch"] }

      /// UserSearch
      ///
      /// Parent Type: `User`
      public struct UserSearch: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", God.ID.self),
          .field("firstName", String.self),
          .field("lastName", String.self),
          .field("displayName", DisplayName.self),
          .field("username", String?.self),
          .field("imageURL", String.self),
          .field("friendStatus", GraphQLEnum<God.FriendStatus>.self),
          .field("mutualFriendsCount", Int.self),
        ] }

        /// user id
        public var id: God.ID { __data["id"] }
        /// first name
        public var firstName: String { __data["firstName"] }
        /// last name
        public var lastName: String { __data["lastName"] }
        /// 表示名
        public var displayName: DisplayName { __data["displayName"] }
        /// username
        public var username: String? { __data["username"] }
        /// プロフィール画像のURL
        public var imageURL: String { __data["imageURL"] }
        /// フレンドステータス
        public var friendStatus: GraphQLEnum<God.FriendStatus> { __data["friendStatus"] }
        /// 共通のフレンド数
        public var mutualFriendsCount: Int { __data["mutualFriendsCount"] }

        /// UserSearch.DisplayName
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

}