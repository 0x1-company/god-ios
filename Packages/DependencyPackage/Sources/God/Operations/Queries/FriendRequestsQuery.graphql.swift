// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class FriendRequestsQuery: GraphQLQuery {
    public static let operationName: String = "FriendRequests"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query FriendRequests($first: Int!) { friendRequests(first: $first) { __typename edges { __typename node { __typename ...FriendRequestCardFragment } } } }"#,
        fragments: [FriendRequestCardFragment.self]
      ))

    public var first: Int

    public init(first: Int) {
      self.first = first
    }

    public var __variables: Variables? { ["first": first] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("friendRequests", FriendRequests.self, arguments: ["first": .variable("first")]),
      ] }

      /// フレンドリクエスト一覧
      public var friendRequests: FriendRequests { __data["friendRequests"] }

      /// FriendRequests
      ///
      /// Parent Type: `FriendConnection`
      public struct FriendRequests: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.FriendConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("edges", [Edge].self),
        ] }

        public var edges: [Edge] { __data["edges"] }

        /// FriendRequests.Edge
        ///
        /// Parent Type: `FriendEdge`
        public struct Edge: God.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { God.Objects.FriendEdge }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("node", Node.self),
          ] }

          public var node: Node { __data["node"] }

          /// FriendRequests.Edge.Node
          ///
          /// Parent Type: `Friend`
          public struct Node: God.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { God.Objects.Friend }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(FriendRequestCardFragment.self),
            ] }

            public var id: God.ID { __data["id"] }
            /// フレンド状態
            public var status: GraphQLEnum<God.FriendStatus> { __data["status"] }
            /// ユーザー情報
            public var user: FriendRequestCardFragment.User { __data["user"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var friendRequestCardFragment: FriendRequestCardFragment { _toFragment() }
            }
          }
        }
      }
    }
  }

}