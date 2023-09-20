// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class InboxActivitiesQuery: GraphQLQuery {
    public static let operationName: String = "InboxActivities"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query InboxActivities($first: Int!, $after: String) { listInboxActivities(first: $first, after: $after) { __typename pageInfo { __typename hasNextPage } edges { __typename cursor node { __typename id initial isRead createdAt question { __typename text { __typename ja } } } } } }"#
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
        .field("listInboxActivities", ListInboxActivities.self, arguments: [
          "first": .variable("first"),
          "after": .variable("after")
        ]),
      ] }

      /// 自分に対するActivityを一覧で取得する
      public var listInboxActivities: ListInboxActivities { __data["listInboxActivities"] }

      /// ListInboxActivities
      ///
      /// Parent Type: `InboxActivityConnection`
      public struct ListInboxActivities: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.InboxActivityConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("edges", [Edge].self),
        ] }

        public var pageInfo: PageInfo { __data["pageInfo"] }
        public var edges: [Edge] { __data["edges"] }

        /// ListInboxActivities.PageInfo
        ///
        /// Parent Type: `PageInfo`
        public struct PageInfo: God.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { God.Objects.PageInfo }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("hasNextPage", Bool.self),
          ] }

          /// 次のページがあるかどうか
          public var hasNextPage: Bool { __data["hasNextPage"] }
        }

        /// ListInboxActivities.Edge
        ///
        /// Parent Type: `InboxActivityEdge`
        public struct Edge: God.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { God.Objects.InboxActivityEdge }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("cursor", String.self),
            .field("node", Node.self),
          ] }

          public var cursor: String { __data["cursor"] }
          public var node: Node { __data["node"] }

          /// ListInboxActivities.Edge.Node
          ///
          /// Parent Type: `InboxActivity`
          public struct Node: God.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { God.Objects.InboxActivity }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", God.ID.self),
              .field("initial", String?.self),
              .field("isRead", Bool.self),
              .field("createdAt", God.Date.self),
              .field("question", Question.self),
            ] }

            /// ID
            public var id: God.ID { __data["id"] }
            /// イニシャル
            public var initial: String? { __data["initial"] }
            /// 既読かどうか
            public var isRead: Bool { __data["isRead"] }
            public var createdAt: God.Date { __data["createdAt"] }
            public var question: Question { __data["question"] }

            /// ListInboxActivities.Edge.Node.Question
            ///
            /// Parent Type: `Question`
            public struct Question: God.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { God.Objects.Question }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("text", Text.self),
              ] }

              /// text
              public var text: Text { __data["text"] }

              /// ListInboxActivities.Edge.Node.Question.Text
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
          }
        }
      }
    }
  }

}