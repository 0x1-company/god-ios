// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class CreateUserHideMutation: GraphQLMutation {
    public static let operationName: String = "CreateUserHide"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CreateUserHide($input: CreateUserHideInput!) { createUserHide(input: $input) { __typename id userId hiddenUserId } }"#
      ))

    public var input: CreateUserHideInput

    public init(input: CreateUserHideInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("createUserHide", CreateUserHide.self, arguments: ["input": .variable("input")]),
      ] }

      public var createUserHide: CreateUserHide { __data["createUserHide"] }

      /// CreateUserHide
      ///
      /// Parent Type: `UserHide`
      public struct CreateUserHide: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.UserHide }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", God.ID.self),
          .field("userId", String.self),
          .field("hiddenUserId", String.self),
        ] }

        public var id: God.ID { __data["id"] }
        public var userId: String { __data["userId"] }
        public var hiddenUserId: String { __data["hiddenUserId"] }
      }
    }
  }

}