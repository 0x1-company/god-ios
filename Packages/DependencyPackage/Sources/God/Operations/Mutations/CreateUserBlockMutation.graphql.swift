// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class CreateUserBlockMutation: GraphQLMutation {
    public static let operationName: String = "CreateUserBlock"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CreateUserBlock($input: CreateUserBlockInput!) { createUserBlock(input: $input) { __typename id userId blockedUserId } }"#
      ))

    public var input: CreateUserBlockInput

    public init(input: CreateUserBlockInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("createUserBlock", CreateUserBlock?.self, arguments: ["input": .variable("input")]),
      ] }

      /// block a user
      public var createUserBlock: CreateUserBlock? { __data["createUserBlock"] }

      /// CreateUserBlock
      ///
      /// Parent Type: `UserBlock`
      public struct CreateUserBlock: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.UserBlock }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", God.ID.self),
          .field("userId", String.self),
          .field("blockedUserId", String.self),
        ] }

        public var id: God.ID { __data["id"] }
        public var userId: String { __data["userId"] }
        public var blockedUserId: String { __data["blockedUserId"] }
      }
    }
  }

}