// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class CurrentUserQuery: GraphQLQuery {
    public static let operationName: String = "CurrentUser"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query CurrentUser { currentUser { __typename id firstName lastName username schoolId school { __typename id name shortName } } }"#
      ))

    public init() {}

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("currentUser", CurrentUser.self),
      ] }

      /// get current user
      public var currentUser: CurrentUser { __data["currentUser"] }

      /// CurrentUser
      ///
      /// Parent Type: `User`
      public struct CurrentUser: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", God.ID.self),
          .field("firstName", String.self),
          .field("lastName", String.self),
          .field("username", String.self),
          .field("schoolId", String?.self),
          .field("school", School?.self),
        ] }

        /// user id
        public var id: God.ID { __data["id"] }
        /// first name
        public var firstName: String { __data["firstName"] }
        /// last name
        public var lastName: String { __data["lastName"] }
        /// username
        public var username: String { __data["username"] }
        public var schoolId: String? { __data["schoolId"] }
        /// school to which the user belongs
        public var school: School? { __data["school"] }

        /// CurrentUser.School
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