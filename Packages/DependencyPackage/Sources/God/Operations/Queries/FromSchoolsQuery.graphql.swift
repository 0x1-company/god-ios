// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class FromSchoolsQuery: GraphQLQuery {
    public static let operationName: String = "FromSchools"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query FromSchools($schoolId: String!, $first: Int!, $after: String) { usersBySchoolId(schoolId: $schoolId, first: $first, after: $after) { __typename pageInfo { __typename ...NextPaginationFragment } edges { __typename cursor node { __typename ...FromSchoolCardFragment } } } }"#,
        fragments: [NextPaginationFragment.self, FromSchoolCardFragment.self]
      ))

    public var schoolId: String
    public var first: Int
    public var after: GraphQLNullable<String>

    public init(
      schoolId: String,
      first: Int,
      after: GraphQLNullable<String>
    ) {
      self.schoolId = schoolId
      self.first = first
      self.after = after
    }

    public var __variables: Variables? { [
      "schoolId": schoolId,
      "first": first,
      "after": after
    ] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("usersBySchoolId", UsersBySchoolId.self, arguments: [
          "schoolId": .variable("schoolId"),
          "first": .variable("first"),
          "after": .variable("after")
        ]),
      ] }

      /// 指定した学校に所属しているユーザー一覧
      public var usersBySchoolId: UsersBySchoolId { __data["usersBySchoolId"] }

      /// UsersBySchoolId
      ///
      /// Parent Type: `UserConnection`
      public struct UsersBySchoolId: God.SelectionSet {
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

        /// UsersBySchoolId.PageInfo
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

        /// UsersBySchoolId.Edge
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

          /// UsersBySchoolId.Edge.Node
          ///
          /// Parent Type: `User`
          public struct Node: God.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(FromSchoolCardFragment.self),
            ] }

            /// user id
            public var id: God.ID { __data["id"] }
            /// 年代
            public var generation: Int? { __data["generation"] }
            /// 表示名
            public var displayName: FromSchoolCardFragment.DisplayName { __data["displayName"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var fromSchoolCardFragment: FromSchoolCardFragment { _toFragment() }
            }
          }
        }
      }
    }
  }

}