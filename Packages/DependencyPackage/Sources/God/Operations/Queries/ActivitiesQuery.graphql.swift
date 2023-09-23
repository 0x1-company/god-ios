// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class ActivitiesQuery: GraphQLQuery {
    public static let operationName: String = "Activities"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Activities($after: String) { listActivities(first: 100, after: $after) { __typename pageInfo { __typename ...NextPaginationFragment } edges { __typename cursor node { __typename id createdAt question { __typename id text { __typename ja } } userId user { __typename imageURL firstName lastName displayName { __typename ja } } } } } }"#,
        fragments: [NextPaginationFragment.self]
      ))

    public var after: GraphQLNullable<String>

    public init(after: GraphQLNullable<String>) {
      self.after = after
    }

    public var __variables: Variables? { ["after": after] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("listActivities", ListActivities.self, arguments: [
          "first": 100,
          "after": .variable("after")
        ]),
      ] }

      /// フレンドのActivityを一覧で取得する
      public var listActivities: ListActivities { __data["listActivities"] }

      /// ListActivities
      ///
      /// Parent Type: `ActivityConnection`
      public struct ListActivities: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.ActivityConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("edges", [Edge].self),
        ] }

        public var pageInfo: PageInfo { __data["pageInfo"] }
        public var edges: [Edge] { __data["edges"] }

        /// ListActivities.PageInfo
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

        /// ListActivities.Edge
        ///
        /// Parent Type: `ActivityEdge`
        public struct Edge: God.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { God.Objects.ActivityEdge }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("cursor", String.self),
            .field("node", Node.self),
          ] }

          public var cursor: String { __data["cursor"] }
          public var node: Node { __data["node"] }

          /// ListActivities.Edge.Node
          ///
          /// Parent Type: `Activity`
          public struct Node: God.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { God.Objects.Activity }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", God.ID.self),
              .field("createdAt", God.Date.self),
              .field("question", Question.self),
              .field("userId", String.self),
              .field("user", User.self),
            ] }

            /// ID
            public var id: God.ID { __data["id"] }
            public var createdAt: God.Date { __data["createdAt"] }
            public var question: Question { __data["question"] }
            /// アクティビティの対象
            public var userId: String { __data["userId"] }
            public var user: User { __data["user"] }

            /// ListActivities.Edge.Node.Question
            ///
            /// Parent Type: `Question`
            public struct Question: God.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { God.Objects.Question }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("id", God.ID.self),
                .field("text", Text.self),
              ] }

              public var id: God.ID { __data["id"] }
              /// text
              public var text: Text { __data["text"] }

              /// ListActivities.Edge.Node.Question.Text
              ///
              /// Parent Type: `LocalizableString`
              public struct Text: God.SelectionSet {
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

            /// ListActivities.Edge.Node.User
            ///
            /// Parent Type: `User`
            public struct User: God.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("imageURL", String.self),
                .field("firstName", String.self),
                .field("lastName", String.self),
                .field("displayName", DisplayName.self),
              ] }

              /// プロフィール画像のURL
              public var imageURL: String { __data["imageURL"] }
              /// first name
              public var firstName: String { __data["firstName"] }
              /// last name
              public var lastName: String { __data["lastName"] }
              /// 表示名
              public var displayName: DisplayName { __data["displayName"] }

              /// ListActivities.Edge.Node.User.DisplayName
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
    }
  }

}