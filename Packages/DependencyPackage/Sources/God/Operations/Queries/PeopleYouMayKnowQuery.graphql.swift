// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class PeopleYouMayKnowQuery: GraphQLQuery {
    public static let operationName: String = "PeopleYouMayKnow"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query PeopleYouMayKnow($first: Int!) { currentUser { __typename ...ProfileStoryFragment } usersBySameSchool(first: $first) { __typename edges { __typename node { __typename id imageURL firstName lastName displayName { __typename ja } grade } } } }"#,
        fragments: [ProfileStoryFragment.self]
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
        .field("currentUser", CurrentUser.self),
        .field("usersBySameSchool", UsersBySameSchool.self, arguments: ["first": .variable("first")]),
      ] }

      /// ログイン中ユーザーを取得
      public var currentUser: CurrentUser { __data["currentUser"] }
      /// 同じ学校に所属しているユーザー一覧
      public var usersBySameSchool: UsersBySameSchool { __data["usersBySameSchool"] }

      /// CurrentUser
      ///
      /// Parent Type: `User`
      public struct CurrentUser: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ProfileStoryFragment.self),
        ] }

        /// プロフィール画像のURL
        public var imageURL: String { __data["imageURL"] }
        /// first name
        public var firstName: String { __data["firstName"] }
        /// username
        public var username: String? { __data["username"] }
        /// 表示名
        public var displayName: ProfileStoryFragment.DisplayName { __data["displayName"] }
        /// 所属している学校
        public var school: ProfileStoryFragment.School? { __data["school"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var profileStoryFragment: ProfileStoryFragment { _toFragment() }
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
              .field("id", God.ID.self),
              .field("imageURL", String.self),
              .field("firstName", String.self),
              .field("lastName", String.self),
              .field("displayName", DisplayName.self),
              .field("grade", String?.self),
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
            /// 学年をテキストで返す
            public var grade: String? { __data["grade"] }

            /// UsersBySameSchool.Edge.Node.DisplayName
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