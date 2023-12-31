// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class FriendsQuery: GraphQLQuery {
    public static let operationName: String = "Friends"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Friends { friends { __typename ...FriendFragment } }"#,
        fragments: [FriendFragment.self]
      ))

    public init() {}

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("friends", [Friend].self),
      ] }

      /// フレンドの一覧
      public var friends: [Friend] { __data["friends"] }

      /// Friend
      ///
      /// Parent Type: `User`
      public struct Friend: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(FriendFragment.self),
        ] }

        /// user id
        public var id: God.ID { __data["id"] }
        /// first name
        public var firstName: String { __data["firstName"] }
        /// last name
        public var lastName: String { __data["lastName"] }
        /// 表示名
        public var displayName: FriendFragment.DisplayName { __data["displayName"] }
        /// プロフィール画像のURL
        public var imageURL: String { __data["imageURL"] }
        /// フレンドステータス
        public var friendStatus: GraphQLEnum<God.FriendStatus> { __data["friendStatus"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var friendFragment: FriendFragment { _toFragment() }
        }
      }
    }
  }

}