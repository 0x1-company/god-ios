// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class CreateUserMutation: GraphQLMutation {
    public static let operationName: String = "CreateUser"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CreateUser($input: CreateUserInput!) { createUser(input: $input) { __typename id } }"#
      ))

    public var input: CreateUserInput

    public init(input: CreateUserInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("createUser", CreateUser.self, arguments: ["input": .variable("input")]),
      ] }

      /// create a user
      public var createUser: CreateUser { __data["createUser"] }

      /// CreateUser
      ///
      /// Parent Type: `User`
      public struct CreateUser: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", God.ID.self),
        ] }

        /// user id
        public var id: God.ID { __data["id"] }
      }
    }
  }
}
