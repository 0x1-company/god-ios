// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class FriendsOfFriendsQuery: GraphQLQuery {
    public static let operationName: String = "FriendsOfFriends"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query FriendsOfFriends($first: Int!, $after: String) { friendsOfFriends(first: $first, after: $after) { __typename pageInfo { __typename ...NextPaginationFragment } edges { __typename cursor node { __typename ...FriendsOfFriendsCardFragment } } } }"#,
        fragments: [NextPaginationFragment.self, FriendsOfFriendsCardFragment.self]
      ))

    public var first: Int
    public var after: GraphQLNullable<String>

    public init(
      first: Int,
      after: GraphQLNullable<String>
    ) {
      self.first = first
      self.after = after
    }

    public var __variables: Variables? { [
      "first": first,
      "after": after
    ] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("friendsOfFriends", FriendsOfFriends.self, arguments: [
          "first": .variable("first"),
          "after": .variable("after")
        ]),
      ] }

      /// フレンドのフレンド一覧
      public var friendsOfFriends: FriendsOfFriends { __data["friendsOfFriends"] }

      /// FriendsOfFriends
      ///
      /// Parent Type: `UserConnection`
      public struct FriendsOfFriends: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.UserConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("edges", [Edge].self),
        ] }

        public var pageInfo: PageInfo { __data["pageInfo"] }
        public var edges: [Edge] { __data["edges"] }

        /// FriendsOfFriends.PageInfo
        ///
        /// Parent Type: `PageInfo`
        public struct PageInfo: God.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { God.Objects.PageInfo }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(NextPaginationFragment.self),
          ] }

          /// 次のページがあるかどうか
          public var hasNextPage: Bool { __data["hasNextPage"] }
          /// 最後のedgeのカーソル
          public var endCursor: String? { __data["endCursor"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var nextPaginationFragment: NextPaginationFragment { _toFragment() }
          }
        }

        /// FriendsOfFriends.Edge
        ///
        /// Parent Type: `UserEdge`
        public struct Edge: God.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { God.Objects.UserEdge }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("cursor", String.self),
            .field("node", Node.self),
          ] }

          public var cursor: String { __data["cursor"] }
          public var node: Node { __data["node"] }

          /// FriendsOfFriends.Edge.Node
          ///
          /// Parent Type: `User`
          public struct Node: God.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(FriendsOfFriendsCardFragment.self),
            ] }

            /// user id
            public var id: God.ID { __data["id"] }
            /// 共通のフレンド数
            public var mutualFriendsCount: Int { __data["mutualFriendsCount"] }
            /// 表示名
            public var displayName: FriendsOfFriendsCardFragment.DisplayName { __data["displayName"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var friendsOfFriendsCardFragment: FriendsOfFriendsCardFragment { _toFragment() }
            }
          }
        }
      }
    }
  }

}