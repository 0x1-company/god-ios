// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class AddPlusQuery: GraphQLQuery {
    public static let operationName: String = "AddPlus"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query AddPlus($first: Int!) { friendRequests(first: 100) { __typename edges { __typename node { __typename ...FriendRequestCardFragment } } } friendsOfFriends(first: $first) { __typename edges { __typename node { __typename ...AddPlusCardFragment } } } usersBySameSchool(first: $first) { __typename edges { __typename node { __typename ...AddPlusCardFragment } } } }"#,
        fragments: [FriendRequestCardFragment.self, AddPlusCardFragment.self]
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
        .field("friendRequests", FriendRequests.self, arguments: ["first": 100]),
        .field("friendsOfFriends", FriendsOfFriends.self, arguments: ["first": .variable("first")]),
        .field("usersBySameSchool", UsersBySameSchool.self, arguments: ["first": .variable("first")]),
      ] }

      /// フレンドリクエスト一覧
      public var friendRequests: FriendRequests { __data["friendRequests"] }
      /// フレンドのフレンド一覧
      public var friendsOfFriends: FriendsOfFriends { __data["friendsOfFriends"] }
      /// 同じ学校に所属しているユーザー一覧
      public var usersBySameSchool: UsersBySameSchool { __data["usersBySameSchool"] }

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

      /// FriendsOfFriends
      ///
      /// Parent Type: `UserConnection`
      public struct FriendsOfFriends: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.UserConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("edges", [Edge].self),
        ] }

        public var edges: [Edge] { __data["edges"] }

        /// FriendsOfFriends.Edge
        ///
        /// Parent Type: `UserEdge`
        public struct Edge: God.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { God.Objects.UserEdge }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("node", Node.self),
          ] }

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
              .fragment(AddPlusCardFragment.self),
            ] }

            /// user id
            public var id: God.ID { __data["id"] }
            /// プロフィール画像のURL
            public var imageURL: String { __data["imageURL"] }
            /// 表示名
            public var displayName: AddPlusCardFragment.DisplayName { __data["displayName"] }
            /// first name
            public var firstName: String { __data["firstName"] }
            /// last name
            public var lastName: String { __data["lastName"] }
            /// 共通のフレンド数
            public var mutualFriendsCount: Int { __data["mutualFriendsCount"] }
            /// 学年をテキストで返す
            public var grade: String? { __data["grade"] }
            /// フレンドステータス
            public var friendStatus: GraphQLEnum<God.FriendStatus> { __data["friendStatus"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var addPlusCardFragment: AddPlusCardFragment { _toFragment() }
            }
          }
        }
      }

      /// UsersBySameSchool
      ///
      /// Parent Type: `UserConnection`
      public struct UsersBySameSchool: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.UserConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("edges", [Edge].self),
        ] }

        public var edges: [Edge] { __data["edges"] }

        /// UsersBySameSchool.Edge
        ///
        /// Parent Type: `UserEdge`
        public struct Edge: God.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { God.Objects.UserEdge }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("node", Node.self),
          ] }

          public var node: Node { __data["node"] }

          /// UsersBySameSchool.Edge.Node
          ///
          /// Parent Type: `User`
          public struct Node: God.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(AddPlusCardFragment.self),
            ] }

            /// user id
            public var id: God.ID { __data["id"] }
            /// プロフィール画像のURL
            public var imageURL: String { __data["imageURL"] }
            /// 表示名
            public var displayName: AddPlusCardFragment.DisplayName { __data["displayName"] }
            /// first name
            public var firstName: String { __data["firstName"] }
            /// last name
            public var lastName: String { __data["lastName"] }
            /// 共通のフレンド数
            public var mutualFriendsCount: Int { __data["mutualFriendsCount"] }
            /// 学年をテキストで返す
            public var grade: String? { __data["grade"] }
            /// フレンドステータス
            public var friendStatus: GraphQLEnum<God.FriendStatus> { __data["friendStatus"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var addPlusCardFragment: AddPlusCardFragment { _toFragment() }
            }
          }
        }
      }
    }
  }

}