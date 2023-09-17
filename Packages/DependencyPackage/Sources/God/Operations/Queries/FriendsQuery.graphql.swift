// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class FriendsQuery: GraphQLQuery {
    public static let operationName: String = "Friends"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Friends($first: Int!, $after: String) { friends(first: $first, after: $after) { __typename pageInfo { __typename ...NextPaginationFragment } edges { __typename cursor node { __typename ...FriendFragment } } } }"#,
        fragments: [NextPaginationFragment.self, FriendFragment.self]
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
        .field("friends", Friends.self, arguments: [
          "first": .variable("first"),
          "after": .variable("after")
        ]),
      ] }

      /// フレンドの一覧
      public var friends: Friends { __data["friends"] }

      /// Friends
      ///
      /// Parent Type: `UserConnection`
      public struct Friends: God.SelectionSet {
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

        /// Friends.PageInfo
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

        /// Friends.Edge
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

          /// Friends.Edge.Node
          ///
          /// Parent Type: `User`
          public struct Node: God.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(FriendFragment.self),
            ] }

            /// user id
            public var id: God.ID { __data["id"] }
            /// 表示名
            public var displayName: FriendFragment.DisplayName { __data["displayName"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var friendFragment: FriendFragment { _toFragment() }
            }
          }
        }
      }
    }
  }

}