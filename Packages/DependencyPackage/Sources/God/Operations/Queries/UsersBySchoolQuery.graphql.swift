// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class UsersBySchoolQuery: GraphQLQuery {
    public static let operationName: String = "UsersBySchool"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query UsersBySchool($schoolId: String!, $first: Int!) { usersBySchoolId(schoolId: $schoolId, first: $first) { __typename edges { __typename node { __typename id imageURL firstName lastName displayName { __typename ja } } } } }"#
      ))

    public var schoolId: String
    public var first: Int

    public init(
      schoolId: String,
      first: Int
    ) {
      self.schoolId = schoolId
      self.first = first
    }

    public var __variables: Variables? { [
      "schoolId": schoolId,
      "first": first
    ] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("usersBySchoolId", UsersBySchoolId.self, arguments: [
          "schoolId": .variable("schoolId"),
          "first": .variable("first")
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
          .field("edges", [Edge].self),
        ] }

        public var edges: [Edge] { __data["edges"] }

        /// UsersBySchoolId.Edge
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

          /// UsersBySchoolId.Edge.Node
          ///
          /// Parent Type: `User`
          public struct Node: God.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", God.ID.self),
              .field("imageURL", String.self),
              .field("firstName", String.self),
              .field("lastName", String.self),
              .field("displayName", DisplayName.self),
            ] }

            /// user id
            public var id: God.ID { __data["id"] }
            /// プロフィール画像のURL
            public var imageURL: String { __data["imageURL"] }
            /// first name
            public var firstName: String { __data["firstName"] }
            /// last name
            public var lastName: String { __data["lastName"] }
            /// 表示名
            public var displayName: DisplayName { __data["displayName"] }

            /// UsersBySchoolId.Edge.Node.DisplayName
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