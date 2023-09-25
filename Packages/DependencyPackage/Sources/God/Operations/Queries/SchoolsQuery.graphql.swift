// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class SchoolsQuery: GraphQLQuery {
    public static let operationName: String = "Schools"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Schools($first: Int!, $after: String) { schools(first: $first, after: $after) { __typename edges { __typename node { __typename id name shortName usersCount } } } }"#
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
        .field("schools", Schools.self, arguments: [
          "first": .variable("first"),
          "after": .variable("after")
        ]),
      ] }

      /// スクール一覧
      public var schools: Schools { __data["schools"] }

      /// Schools
      ///
      /// Parent Type: `SchoolConnection`
      public struct Schools: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.SchoolConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("edges", [Edge].self),
        ] }

        public var edges: [Edge] { __data["edges"] }

        /// Schools.Edge
        ///
        /// Parent Type: `SchoolEdge`
        public struct Edge: God.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { God.Objects.SchoolEdge }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("node", Node.self),
          ] }

          public var node: Node { __data["node"] }

          /// Schools.Edge.Node
          ///
          /// Parent Type: `School`
          public struct Node: God.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { God.Objects.School }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", God.ID.self),
              .field("name", String.self),
              .field("shortName", String.self),
              .field("usersCount", Int.self),
            ] }

            public var id: God.ID { __data["id"] }
            /// 学校名
            public var name: String { __data["name"] }
            /// 学校名（略称）
            public var shortName: String { __data["shortName"] }
            /// スクールに所属しているユーザー数
            public var usersCount: Int { __data["usersCount"] }
          }
        }
      }
    }
  }

}