// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class UserQuery: GraphQLQuery {
    public static let operationName: String = "User"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query User($where: UserWhere!) { user(where: $where) { __typename id firstName lastName username schoolId school { __typename id name shortName } ...ProfileSectionFragment } }"#,
        fragments: [ProfileSectionFragment.self]
      ))

    public var `where`: UserWhere

    public init(`where`: UserWhere) {
      self.`where` = `where`
    }

    public var __variables: Variables? { ["where": `where`] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("user", User.self, arguments: ["where": .variable("where")]),
      ] }

      /// get user
      public var user: User { __data["user"] }

      /// User
      ///
      /// Parent Type: `User`
      public struct User: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", God.ID.self),
          .field("firstName", String.self),
          .field("lastName", String.self),
          .field("username", String?.self),
          .field("schoolId", String?.self),
          .field("school", School?.self),
          .fragment(ProfileSectionFragment.self),
        ] }

        /// user id
        public var id: God.ID { __data["id"] }
        /// first name
        public var firstName: String { __data["firstName"] }
        /// last name
        public var lastName: String { __data["lastName"] }
        /// username
        public var username: String? { __data["username"] }
        public var schoolId: String? { __data["schoolId"] }
        /// school to which the user belongs
        public var school: School? { __data["school"] }
        /// 年代
        public var generation: Int? { __data["generation"] }
        /// friends count
        public var friendsCount: Int? { __data["friendsCount"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var profileSectionFragment: ProfileSectionFragment { _toFragment() }
        }

        /// User.School
        ///
        /// Parent Type: `School`
        public struct School: God.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { God.Objects.School }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", God.ID.self),
            .field("name", String.self),
            .field("shortName", String.self),
          ] }

          public var id: God.ID { __data["id"] }
          /// 学校名
          public var name: String { __data["name"] }
          /// 学校名（略称）
          public var shortName: String { __data["shortName"] }
        }
      }
    }
  }

}